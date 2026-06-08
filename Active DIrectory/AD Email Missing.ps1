$searchBase = 'dc=DOMAIN,dc=COM' #Customize

$Created = (Get-Date).AddDays(-30)
$NewADAccsHeader = "~~~~~ New Accounts Missing Emails ~~~~~`n"
$NewADAccs = Get-ADUser -Filter {
    (Enabled -eq $True)
    -and (mail -notlike '*')
    -and (Created -gt $Created)
    } -SearchBase $searchBase -Properties givenName,sn,mail,whenCreated,Enabled | Select-Object givenName,sn,mail | Export-Csv -NoType "$PSScriptRoot\AD Email Missing.csv"

if (!$NewADAccs) {
    $NewADAccs = "There are no new accounts.`n"
}
$NewADAccs = $NewADAccsHeader + $NewADAccs

$NewADAccs