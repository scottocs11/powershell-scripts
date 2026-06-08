$drive = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -eq "C:\"}
$freeSpaceGB = [Math]::Round($drive.Free / 1GB, 2)
$totalSpaceGB = [Math]::Round($drive.Used / 1GB + $drive.Free / 1GB, 2)
$freePercentage = [Math]::Round(($freeSpaceGB / $totalSpaceGB) * 100, 2)

Write-Host "Drive Letter: C:"
Write-Host "Free Space: $freeSpaceGB GB"
Write-Host "Total Space: $totalSpaceGB GB"
Write-Host "Free Space Percentage: $freePercentage%"

if ($freePercentage -lt 10) {
    Write-Host Less than 10%
}
if ($freePercentage -lt 50) {
    Write-Host Less than 50%
}