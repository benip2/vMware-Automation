#פרטים לחיבור השרת
$esxiHost = "ESXI_IP"
$esxiUser = "Root_Username"
$esxiPassword = "Root_Password"

#כניסה לשרת
Connect-VIServer -Server $esxiHost -User $esxiUser -Password $esxiPassword

#כיבוי כל המכונות הוירטואליות בשרת
$vmList = Get-VM
foreach ($vm in $vmList) {
    if ($vm.PowerState -eq "PoweredOn") {
        Write-Host "Shutting down VM: $($vm.Name)"
        Shutdown-VMGuest -VM $vm -Confirm:$false    #כיבוי המכונה
    }
}

#מחכה לכיבוי המכונות
$vmShutdownComplete = $false
while (-not $vmShutdownComplete) {
    $poweredOnVms = Get-VM | Where-Object { $_.PowerState -eq "PoweredOn" }
    if ($poweredOnVms.count -eq 0) {
        $vmShutdownComplete = $true
    } else {
        Write-Host "waiting for VMs to shutdown.."
        Start-Sleep -Seconds 5
        }
    }

Write-Host "All VMs are powered off."

#ESXI כיבוי ה
Stop-VMHost -VMHost $esxiHost -force -Confirm:$false

#התנתקות מהשרת
Disconnect-VIServer -Server $esxiHost -Confirm:$false
