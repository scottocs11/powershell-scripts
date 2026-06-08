### MUST RUN IN ISE x86!??? ###

$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}

Get-VM |
Where{Get-NetworkAdapter -VM $_ | where{$_.Type -eq 'e1000e'}} |
Select Name