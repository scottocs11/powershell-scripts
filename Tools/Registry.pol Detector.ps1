[CmdletBinding()]
$Computers = 'PCname'

 if (Test-NetConnection –ComputerName $computer –Hops 1 –InformationLevel Quiet –ErrorAction SilentlyContinue –WarningAction SilentlyContinue)
 {
 if (Test-Path –Path \\$computer\c$\Windows\System32\GroupPolicy\Machine\Registry.pol –ErrorAction SilentlyContinue –WarningAction SilentlyContinue)
 {
 $regpol= Get-Childitem \\$computer\c$\Windows\System32\GroupPolicy\Machine\Registry.pol
 if ($regpol.LastWriteTime -lt (get-date).AddDays(-1))
 {
 Write-Host "$computer Registry.pol file is old ("$regpol.LastWriteTime")" –ForegroundColor Magenta
 #Write-Host "$computer Registry.pol file is old ("$regpol.LastWriteTime"), deleting and forcing a GPUpdate" –ForegroundColor Magenta
 Remove-Item $regpol
 #Invoke-WmiMethod –Name create –Path win32_process –ArgumentList "gpupdate /target:Computer /force /wait:0" –AsJob –ComputerName $computer | out-null
 }
 else
 {
 Write-Host "$computer Registry.pol file is healthy ("$regpol.LastWriteTime")" –ForegroundColor Green
 } 
 }
 elseif (Test-Path –Path \\$computer\c$\Windows\System32\GroupPolicy\Machine\ –ErrorAction SilentlyContinue –WarningAction SilentlyContinue)
 {
 Write-Host "$computer doesn't have a Registry.pol file" –ForegroundColor Magenta
 #Write-Host "$computer doesn't have a Registry.pol file, forcing a GPUpdate" –ForegroundColor Magenta
 #Invoke-WmiMethod –Name create –Path win32_process –ArgumentList "gpupdate /target:Computer /force /wait:0" –AsJob –ComputerName $computer | out-null
 }
 
 else
 {
 Write-Warning "$computer does not have c:\Windows\System32\GroupPolicy\Machine\ or you don't have access"
 }
 } 
 else
 {
 Write-Warning "Unable to find or contact $computer"
 }
