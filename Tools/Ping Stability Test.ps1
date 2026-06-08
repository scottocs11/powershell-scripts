#Customizable
$ip = "192.168.1.10"
$numPings = 1000

#Don't Touch
$count= 0
$offlineCount = 0
$onlineCount = 0

Do {
    $ping = [string](ping $ip -n 1)
    #Write-Host $ping
    if ($ping.Contains("Lost = 1") -or $ping.Contains("timed out") -or $ping.Contains("could not find")) {
        $offlineCount = $offlineCount + 1
        $result = "Failed"
    } else {
        $onlineCount = $onlineCount + 1
        $result = "Success"
        Start-Sleep -Seconds 1
      }
    $count = $count + 1
    Write-Host "Ping $count of $numPings : $result - $onlineCount Successful and $offlineCount Failed"
} until ($count -eq $numPings)

#$ratio = ($onlineCount / $count) * 100
$ratio = ($onlineCount / $count).ToString("P")
Write-Host "Complete. $ratio Success"