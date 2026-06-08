<#
script change office channel
Channels:
- MonthlyEnterprise (Cameyo Default)
- BetaChannel 
- Current
#>
#------------------------------------------------------
## Enter target channels here ##
$Channel = "MonthlyEnterprise"
#------------------------------------------------------
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
Write-Host -Object ("Identity Name: " + $identity.Name)
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($isAdmin -eq $false) {
  Write-Host "Running as Administrator " -ForegroundColor red
  break
}

Set-Location -Path "C:\Program Files\Common Files\Microsoft Shared\ClickToRun" 
# Force Update
$UpdateEXE = "OfficeC2RClient.exe"
$UpdateChannel = "/changesetting Channel=$Channel"
$UpdateArguements = "/update user displaylevel=true"

write-host ""
$answer = read-host "Press y to start, any other key to abort."
if ($answer -eq 'y') { 
  # Delete OfficeUpdate
  if (Test-Path -path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate") {
    write-host ""
    write-host "CAUTION: Office update is disabled, try to delete" -ForegroundColor red
    write-host ""
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "*"-force 
    Start-Sleep -Seconds 5
  }

  write-host ""
  write-host "-------------------------------------------" -ForegroundColor green
  Write-host "Change Office channel to $Channel" -ForegroundColor green
  write-host ""
  write-host "CAUTION: This can take up to 10 Minutes" -ForegroundColor yellow
  write-host "-------------------------------------------" -ForegroundColor green
  write-host ""
  write-host "$UpdateEXE $UpdateChannel"
  start-process $UpdateEXE $UpdateChannel
  Start-Sleep -Seconds 5
  write-host "$UpdateEXE $UpdateArguements"
  start-process $UpdateEXE $UpdateArguements 
}
else {
  Write-host "script abort" -ForegroundColor yellow
} 
Set-Location -Path $PSScriptRoot
