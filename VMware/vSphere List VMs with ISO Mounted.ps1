### MUST RUN IN ISE x86!??? ###

$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}l

#List VMs with ISO Mounts
Get-VM | Where-Object { $_.Name -notlike '*VLab*'} | Where {$_.ISOPath -ne $null} | FT Name, @{Label="ISO file"; Expression = { ($_ | Get-CDDrive).ISOPath }} #| Sort-Object -Property "ISO file" -Descending #| Select @{N='VM';E={$_.Parent.Name}},Name,IsoPath

#Uncomment Below to Remove ISO Mounts from VMs
#Get-VM | Where-Object { $_.Name -notlike '*VLab*'} | Get-CDDrive | Where {$_.ISOPath -ne $null} #| Set-CDDrive -NoMedia -Confirm:$false
