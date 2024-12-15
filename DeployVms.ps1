Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Define the vCenter or ESXi server credentials 
$server = "vcenter_or_esxi_server" 
$username = "your_username"
$password = "your_password"

# Connect to the vCenter or ESXi server
Connect-VIServer -Server $server -User $username -Password $password

# Define VM configurations
$vms = @(
    @{
        Name = "VM1"
        CPU = 2           # Total CPU cores
        CoresPerSocket = 1
        MemoryGB = 16
        DiskGB = 100
        StorageProvision = "Thin" # Options: Thin or Thick
        Network = "VM Network"
        Datastore = "DataStore1"
        ISO = "[DataStore1] ISO/Win11.iso"
    },
    @{
        Name = "VM2"
        CPU = 32
        CoresPerSocket = 4
        MemoryGB = 32
        DiskGB = 500
        StorageProvision = "Thin"
        Network = "VM Network"
        Datastore = "DataStore1"
        ISO = "[Datastore1] ISO/Ubuntu.iso"
    },
    @{
        Name = "VM3"
        CPU = 16
        CoresPerSocket = 2
        MemoryGB = 8
        DiskGB = 1000
        StorageProvision = "Thin"
        Network = "VM Network"
        Datastore = "DataStore1"
        ISO = "[Datastore1] ISO/Ubuntu.iso"
    }
)

# Loop through the VM configurations and create VMs
foreach ($vm in $vms) {
    Write-Host "Creating VM: $($vm.Name)"

    # Create the VM without any hard disk
    $newVM = New-VM -Name $vm.Name `
                    -ResourcePool (Get-ResourcePool -Name "Resources") `
                    -Datastore $vm.Datastore `
                    -NumCpu $vm.CPU `
                    -MemoryGB $vm.MemoryGB `
                    -GuestId "otherGuest" `
                    -Confirm:$false

    # Add Network Adapter after VM is created
    Add-NetworkAdapter -VM $newVM -NetworkName $vm.Network -AdapterType "vmxnet3" -Confirm:$false

    # Configure CPU sockets and cores per socket
    Set-VM -VM $newVM -NumCpu $vm.CPU -CoresPerSocket $vm.CoresPerSocket -Confirm:$false

    # Add the required disk with specified provisioning type (20GB)
    $diskProvision = if ($vm.StorageProvision -eq "Thin") { "Thin" } else { "Thick" }
    New-HardDisk -VM $newVM -CapacityGB $vm.DiskGB -Datastore $vm.Datastore -StorageFormat $diskProvision -Confirm:$false

    # Ensure no additional disks are created by clearing the default disk
    Get-HardDisk -VM $newVM | Where-Object { $_.CapacityGB -ne $vm.DiskGB } | Remove-HardDisk -Confirm:$false

    # Add the CD drive (ISO mounting) and connect it
    New-CDDrive -VM $newVM -IsoPath $vm.ISO -Confirm:$false
    Set-CDDrive -VM $newVM -Connected:$true -Confirm:$false
}

# Disconnect from the server
Disconnect-VIServer -Server $server -Confirm:$false
