$portGroup = "Port Group Name"
$newVlanID = "101"

$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.domain.com -Credential $credential
    $Connected = 1}

#List Only
Get-VirtualPortGroup -Name $portGroup

#List and Change. Uncomment to enable change
#Get-VirtualPortGroup -Name $portGroup | Set-VirtualPortGroup -VLanId $newVlanID