$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}

Get-Datastore | Get-VM | Get-HardDisk | Where {$_.storageformat -eq "Thick" } | Select Parent, Name, CapacityGB, storageformat | FT -AutoSize
Pause