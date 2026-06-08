$totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue / 1000
$availMem2 = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
$totalMem = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
$date + ' > CPU: ' + $cpuTime.ToString("#,0.0") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'GB / ' + $totalMem + 'GB (' + (104857600 * $availMem2 / $totalRam).ToString("#,0.0") + '%)'