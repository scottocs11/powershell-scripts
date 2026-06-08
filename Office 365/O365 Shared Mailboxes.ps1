if ($Connected -ne 1) {
    Connect-ExchangeOnline
    $Connected = 1}

Get-Mailbox -Filter {recipienttypedetails -eq 'SharedMailbox'} | Get-Mailboxpermission | Where-Object {$_.user.tostring() -ne "NT AUTHORITY\SELF"
    -and $_.user.tostring() -notlike "S-1-5-21*" #Optional Filter
    -and $_.identity -notlike "0*"} | #Optional Filter
    Select-Object User,Identity | Sort-Object Identity | Export-CSV -Encoding UTF8 -NoTypeInformation "$PSScriptRoot\O365 Shared Mailboxes.csv"