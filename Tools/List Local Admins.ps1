$domain = "domain"
$tld = "com"
$Computers = Get-ADComputer -filter "Enabled -eq 'True'" -SearchBase "OU=Servers,DC=$domain,DC=$tld"

foreach ($comp in $computers) {
Invoke-Command -ComputerName $comp.Name -ScriptBlock{Get-LocalGroupMember -Group "Administrators" | Where Name -NotLike $domain*} | Select-Object Name
    If (!$error) {
        $Excel = [PSCustomObject]@{
            Accounts = $comp.Name
        }
$Excel | Export-Csv "$PSScriptRoot\ServerLocalAdmins.csv" -Append -NoTypeInformation
}
}