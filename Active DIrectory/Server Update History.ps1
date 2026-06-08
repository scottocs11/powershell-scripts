$servers = Get-ADComputer -filter "Enabled -eq 'True'" -SearchBase "OU=Servers,DC=mktalliance,DC=com" | Sort Name | select -Unique Name

$report = foreach ($server in $servers) {
#foreach ($server in $servers) {
    write-host $server.Name
    Invoke-Command -ComputerName $server.Name -ScriptBlock {
    (Get-HotFix |?{$_.InstalledOn -gt ((Get-Date).AddDays(-90))})
    }
}

$report | Export-Csv "$PSScriptRoot\ServerUpdateHistory.csv" -NoTypeInformation