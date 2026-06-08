$Date = (Get-Date).tostring("MM-dd-yyyy")
$File = "$PSScriptRoot\BitlockerKeys " + $Date + ".csv"

Get-ADComputer -Filter * -SearchBase 'OU=Computers,DC=DOMAIN,DC=com' -Properties name,'msTPM-OwnerInformation' | sort name | select name,@{n='RecoveryKey';e={[string]::Join(', ', (Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $_.DistinguishedName -Properties 'msFVE-RecoveryPassword').'msFVE-RecoveryPassword')}} | Export-CSV -NoType $File