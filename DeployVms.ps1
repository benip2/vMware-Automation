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
        MemoryGB = 4
        DiskGB = 40
        StorageProvision = "Thin" # Options: Thin or Thick
        Network = "VM Network"
        Datastore = "Datastore1"
        ISO = "[Datastore1] ISO/Ubuntu.iso"
    },
    @{
        Name = "VM2"
        CPU = 4
        CoresPerSocket = 2
        MemoryGB = 8
        DiskGB = 80
        StorageProvision = "Thick"
        Network = "VM Network"
        Datastore = "Datastore2"
        ISO = "[Datastore2] ISO/CentOS.iso"
    },
    @{
        Name = "VM3"
        CPU = 6
        CoresPerSocket = 3
        MemoryGB = 16
        DiskGB = 120
        StorageProvision = "Thin"
        Network = "VM Network"
        Datastore = "Datastore1"
        ISO = "[Datastore1] ISO/Windows.iso"
    }
)

# Loop through the VM configurations and create VMs
foreach ($vm in $vms) {
    Write-Host "Creating VM: $($vm.Name)"

    # Calculate the number of sockets
    $numSockets = [math]::Ceiling($vm.CPU / $vm.CoresPerSocket)

    # Create the VM
    $newVM = New-VM -Name $vm.Name `
                    -ResourcePool (Get-ResourcePool -Name "Resources") `
                    -Datastore $vm.Datastore `
                    -NumCpu $vm.CPU `
                    -MemoryGB $vm.MemoryGB `
                    -GuestId "otherGuest" `
                    -NetworkAdapterName $vm.Network `
                    -CD -Confirm:$false

    # Configure CPU sockets and cores per socket
    Get-VM $vm.Name | Set-VM -NumCpu $vm.CPU -CoresPerSocket $vm.CoresPerSocket -Confirm:$false

    # Add a disk with specified provisioning type
    $diskProvision = if ($vm.StorageProvision -eq "Thin") { "Thin" } else { "Thick" }
    New-HardDisk -VM $vm.Name -CapacityGB $vm.DiskGB -Datastore $vm.Datastore -StorageFormat $diskProvision -Confirm:$false

    # Mount the ISO file
    $cdDrive = Get-CDDrive -VM $vm.Name
    Set-CDDrive -CDDrive $cdDrive -IsoPath $vm.ISO -Connected:$true -Confirm:$false
}

# Disconnect from the server
Disconnect-VIServer -Server $server -Confirm:$false

