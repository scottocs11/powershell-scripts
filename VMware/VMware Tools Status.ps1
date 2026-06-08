$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
Connect-VIServer vcenter.DOMAIN.com -Credential $credential
Write-Host "VMware Not Installed on:"
Get-VM | ?{$_.extensiondata.guest.toolsstatus -eq 'toolsNotInstalled'} | Select-Object Name
Write-Host "VMware Tools Status:"
Get-vm | get-vmguest | select VMName, ToolsVersion | FT -autosize