$oldNetwork = "OLD Network" #Customzie
$newNetwork = "NEW Network" #Customize

$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}

Get-VM | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq $oldNetwork} | Set-NetworkAdapter -NetworkName $newNetwork -Confirm:$false 