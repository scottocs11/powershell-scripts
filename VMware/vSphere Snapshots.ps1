$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}

Get-VM | Get-Snapshot | select VM, Name, Created, Description, Sizegb
Pause