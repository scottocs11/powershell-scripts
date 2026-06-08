$Connected = 0
$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.domain.com -Credential $credential
    $Connected = 1}

Import-Module "$PSScriptRoot\foundationcoreandtibusage.psm1"

Get-FoundationCoreAndTiBUsage -DeploymentType VVF