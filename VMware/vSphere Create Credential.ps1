$credential = Get-Credential
$credential | Export-Clixml -Path "$PSScriptRoot\vsphere.cred"