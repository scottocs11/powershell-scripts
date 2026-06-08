### MUST RUN IN ISE x86! ###

$credential = Import-Clixml -Path "$PSScriptRoots\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}

#List VMs with ISO Mounts
Get-VM | FT Name, @{Label="ISO file"; Expression = { ($_ | Get-CDDrive).ISOPath }} 

#Uncomment Below to Remove ISO Mounts from VMs
#Get-VM | Get-CDDrive | Where {$_.ISOPath -ne $null} #| Set-CDDrive -NoMedia -Confirm:$false