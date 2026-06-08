$date = (get-date).AddDays(-90)
$FileDate = (Get-Date).tostring("MM-dd-yyyy")
$File = "$PSScriptRoot\AD Users Not Logged in 90 Days - " + $FileDate + ".csv"
Get-ADUser -Filter {LastLogonDate -lt $date -and Enabled -eq $true} -SearchBase 'ou=users,dc=DOMAIN,dc=com' -properties LastLogonDate, DistinguishedName,mail | Select-Object Name, LastLogonDate, mail, Enabled, DistinguishedName | Export-Csv -NoType $File