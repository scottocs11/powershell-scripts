$cmd = 'new-object -com "Microsoft.Update.Session";$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates'
$cmd
Start-sleep -seconds 10
wuauclt /detectnow
(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
wuauclt /reportnow
c:\windows\system32\UsoClient.exe startscan