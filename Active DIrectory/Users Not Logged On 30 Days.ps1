$File = "$PSScriptRoot\Users Not Logged On 30 Days - " + $Date + ".csv"
$Date = (Get-Date).tostring("MM-dd-yyyy")
$7Days = (Get-Date).AddDays(-7)
$30Days = (Get-Date).AddDays(-30)
$60Days = (Get-Date).AddDays(-60)

Get-ADUser -Properties Description,WhenCreated,LastLogonDate -Filter {
(lastlogondate -le $30days) 
-AND (whencreated -le $30days) 
-AND (enabled -eq $True) 
} -SearchBase 'dc=DOMAIN,dc=com' | Select-object Name,Description,LastLogonDate,WhenCreated,DistinguishedName | Export-Csv -NoType $File