### New AD Accounts - Monthly Report

# Get the first day of the current month
$firstDayOfThisMonth = Get-Date -Day 1

# Get the last day of the previous month
$lastDayOfPrevMonth = $firstDayOfThisMonth.AddDays(-1)

# Get the first day of the previous month
$firstDayOfPrevMonth = Get-Date -Year $lastDayOfPrevMonth.Year -Month $lastDayOfPrevMonth.Month -Day 1

# Set the date range for filtering
$Created = $firstDayOfPrevMonth
$date = Get-Date -Format "dddd MM/dd/yyyy"
$Month = (Get-Date).AddMonths(-1).ToString("MMMM")
Write-Output $Month
$Message = "Monthly AD Accounts for $Month`n`n"

$NewADAccs = Get-ADUser -Filter {
    (Enabled -eq $True) -and (Created -ge $Created)
} -SearchBase 'ou=Users,dc=$domain,dc=$tld' -Properties displayName,mail,whenCreated,Enabled,NTSecurityDescriptor,SAMAccountName | 
Select-Object displayName,@{n='OU';e={($_.DistinguishedName.Split(",") | Where-Object {-Not $_.StartsWith("CN=")}) -join ","}},whenCreated,mail,SAMAccountName | 
Sort-Object whencreated -Descending

foreach ($user in $NewADAccs) {
    $AccountName = $user.SAMAccountName
    $ADObject = (Get-ADObject -Filter {(objectClass -eq "user") -and (objectCategory -eq "user") -and (SamAccountName -eq $AccountName)} -Properties NTSecurityDescriptor).NTSecurityDescriptor.owner
    $ADObject = $ADObject.Replace("$domain\", "")
    $OwnerFName = Get-ADUser -Filter "samaccountname -like '$ADObject'" | Select-Object -ExpandProperty givenName
    $OwnerLName = Get-ADUser -Filter "samaccountname -like '$ADObject'" -Properties sn | Select-Object -ExpandProperty sn
    $OwnerName = $OwnerFName + ' ' + $OwnerLName
    $name = $user.displayName
    $when =  $user.whenCreated
    $ou = $user.OU
    $mail = $user.mail
    if ($mail -eq $NULL) { $mail = "MISSING!" }
    $userLine = "$OwnerName created $name at $when in OU $ou with email $mail`n`n"
    $Message += $userLine
    $Message = $Message -replace ",OU=Users,DC=$domain,DC=$tld",""
    $Message = $Message -replace "OU=",""
    $Message = $Message -replace "CN=",""
}

$subject = "$Month New AD Accounts"
$email = @{
    From = "DailyADAccounts@$domain.$tld"
    To = "DailyADAccounts@$domain.$tld"
    Subject = $subject
    SMTPServer = "relay.$domain.com"
    Body = $Message
}
Send-MailMessage @email

if (!$NewADAccs) {
    $Message = "There are no new AD accounts."
    #$subject = "No New AD Accounts | $date"
}
