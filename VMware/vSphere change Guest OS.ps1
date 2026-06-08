$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"
if ($Connected -ne 1) {
    Connect-VIServer vcenter.DOMAIN.com -Credential $credential
    $Connected = 1}

#DOESN'T WORK


#Manual
$vm = "VM Name"
Shutdown-VMGuest -VM $vm -Confirm:$false #-WhatIf
Set-VM -VM $vm -GuestID  "Microsoft Windows Server 2016 (64-bit)" -Confirm:$false
Start-VM -VM $vm -Confirm:$false #-WhatIf


# List VMs on host
#Get-VM | Where VMHost -like '10.1.98.100' | Select Name,VMHost

# Move all on host to another host
#Get-VM | Where VMHost -like '10.1.98.100' | Select Name,VMHost | Foreach {Get-VM $_.Name | Move-VM -Destination (Get-VMHost 10.1.98.101)}

# CSV
#Import-Csv "$PSScriptRoot\vmmigrate.csv" | Foreach {Get-VM $_.Name | Move-VM -Destination (Get-VMHost 10.1.98.101)}