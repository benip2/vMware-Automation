Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
# Define the ESXi host details (you can specify the IP or hostname of the ESXi hosts)
$esxiHosts = @(
    "esxi_host_1_ip_or_hostname",
    "esxi_host_2_ip_or_hostname",
    "esxi_host_3_ip_or_hostname"
)

# VMware credentials
$vmwareUser = "your_vmware_username"
$vmwarePassword = "your_vmware_password"

# Connect to each ESXi host and power on all VMs
foreach ($esxiHost in $esxiHosts) {
    Write-Host "Connecting to ESXi host: $esxiHost"

    # Connect to the ESXi host
    Connect-VIServer -Server $esxiHost -User $vmwareUser -Password $vmwarePassword

    # Get all VMs from the ESXi host
    $vms = Get-VM -Location $esxiHost

    # Power on each VM if it is not already powered on
    foreach ($vm in $vms) {
        if ($vm.PowerState -ne 'PoweredOn') {
            Write-Host "Powering on VM: $($vm.Name)"
            Start-VM -VM $vm
        } else {
            Write-Host "VM $($vm.Name) is already powered on"
        }
    }

    # Disconnect from the ESXi host
    Disconnect-VIServer -Server $esxiHost -Confirm:$false
}

Write-Host "All VMs across specified ESXi hosts have been powered on."
