#Get-VBRCommand

$ip = 10.1.1.100 #Customize
$user = "some.user"

#Save Credential (Set file name)
#$encPassFileName = "$PSScriptRoot\cred.cred"
#(Get-Credential).Password | ConvertFrom-SecureString | Set-Content $encPassFileName

$pass = Get-Content "$PSScriptRoot\cred.cred" | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PsCredential($user,$pass)
Connect-VBRServer -server $ip -Credential $cred
$failed = Get-VBRBackupSession | ? { ( $_.CreationTime -ge (Get-Date).AddDays(-1) ) -and ( $_.Result -ne "Success" ) } | Select Result, CreationTime, JobType, JobName | Sort CreationTime | Format-Table | Out-String
$failedMessage = "~~~~~ Failed ~~~~~`n" + $failed
$failed
if ($failed -eq "") { $failedMessage = "" }
Disconnect-VBRServer

$email = @{
From = "Daily.Veeam@DOMAIN.com"
To = "USER@DOMAIN.com"
Subject = "Daily Veeam"
SMTPServer = "relay.DOMAIN.com"
Body = $failedMessage
}

send-mailmessage @email