$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}

#Remove only snapshots by name
Get-VM | get-snapshot | where Name -like 'backup' | remove-Snapshot -Confirm:$false

#Remove all snapshots
#Get-VM | get-snapshot | remove-Snapshot -Confirm:$false
pause