### New AD Accounts
$Created = (Get-Date).AddDays(-1)
$date = (Get-Date -Format "dddd MM/dd/yyyy")
$Message = "Daily AD Accounts for $date`n`n"

$NewADAccs = Get-ADUser -Filter {
    (Enabled -eq $True)
    -and (Created -gt $Created)
    } -SearchBase 'ou=Users,dc=DOMAIN,dc=com' -Properties displayName,mail,whenCreated,Enabled,NTSecurityDescriptor,SAMAccountName | Select-Object displayName,@{n='OU';e={($_.DistinguishedName.Split(",") | Where-Object {-Not $_.StartsWith("CN=")}) -join ","}},whenCreated,mail,SAMAccountName | Sort-Object whencreated -Descending
    foreach ($user in $NewADAccs) {
    $AccountName = $user.SAMAccountName
    $ADObject = (Get-ADObject -Filter {(objectClass -eq "user") -and (objectCategory -eq "user") -and (SamAccountName -eq $AccountName)} -Properties NTSecurityDescriptor).NTSecurityDescriptor.owner
    $ADObject = $ADObject.Replace("DOMAIN\", "") #Customize
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
    $message = $message -replace ",OU=Users,DC=DOMAIN,DC=com","" #Customize
    $message = $message -replace "OU=",""
    $message = $message -replace "CN=",""
    $subject = "New AD Accounts | $date"
    $email = @{
    From = "DailyADAccounts@DOMAIN.com" #Customize
    To = "DailyADAccounts@DOMAIN.com" #Customize
    Subject = $subject
    SMTPServer = "relay.DOMAIN.com" #CUstomize
    Body = $message
    }
    send-mailmessage @email
}
if (!$NewADAccs) {
   $Message = "There are no new AD accounts."
   #$subject = "No New AD Accounts | $date"
}

#$message