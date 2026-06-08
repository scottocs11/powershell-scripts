$servers = Get-ADComputer -filter "Enabled -eq 'True'" -SearchBase "OU=Servers,DC=DOMAIN,DC=com" | Sort Name | select -Unique Name

foreach ($server in $servers) {
write-host $server.Name

   Invoke-Command -ComputerName $server.Name -ScriptBlock {
(New-Object -com "Microsoft.Update.AutoUpdate"). Results}
}