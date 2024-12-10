Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
# Connect to vCenter Server or ESXI
$server = "vcenter_or_esxi_server"
$username = "Admin_username"
$password = "Admin_password"
Connect-VIServer -Server $server -Username $username -Password $password

# Specify the OVF file path
$ovfPath = "C:\Users\General1\Desktop\TEMPLATE.ovf"

# Datastore = name of datastore
# Import the virtual machine from OVF

Import-VApp -Source $ovfPath -Name "VM1" -VMHost "vcenter_or_esxi_server" -Datastore "DataStoreX"  -DiskStorageFormat Thin | Set-VM -NumCpu 32 -MemoryGB 16 -Confirm:$false
Import-VApp -Source $ovfPath -Name "VM2" -VMHost "vcenter_or_esxi_server" -Datastore "DataStoreY"  -DiskStorageFormat Thin | Set-VM -NumCpu 8 -MemoryGB 16 -Confirm:$false
Import-VApp -Source $ovfPath -Name "VM3" -VMHost "vcenter_or_esxi_server" -Datastore "DataStoreX"  -DiskStorageFormat Thin | Set-VM -NumCpu 8 -MemoryGB 16 -Confirm:$false

# Disconnect from vCenter Server
Disconnect-VIServer -Server $vcServer -Confirm:$false
