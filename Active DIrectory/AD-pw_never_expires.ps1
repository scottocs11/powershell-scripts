get-aduser -filter * -SearchBase "OU=Users,DC=DOMAIN,DC=COM" -properties Name, PasswordNeverExpires | where {
$_.passwordNeverExpires -eq "true" } | where {$_.Enabled -eq $true } | Select-Object Name,SamAccountName |
Export-csv "$PSScriptRoot\AD-pw_never_expires.csv" -NoTypeInformation