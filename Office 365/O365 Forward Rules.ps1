if ($Connected -ne 1) {
    Connect-ExchangeOnline
    $Connected = 1}

Get-Mailbox -Filter {ForwardingSmtpAddress -ne $null} | select UserPrincipalName,ForwardingSmtpAddress,DeliverToMailboxAndForward | Export-csv $PSScriptRoot\'O365 Forward Rules.csv' -NoTypeInformation 