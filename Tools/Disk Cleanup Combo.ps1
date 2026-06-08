# Disk Cleanup
Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:111'

# Remove Old User Profiles
$delete = 1
$threshold = (Get-Date).AddDays(-90) #Set threshold for 90 days
$profiles = Get-CimInstance -ClassName Win32_UserProfile | Where-Object {(!$_.Special) -and ($_.LastUseTime -lt $threshold) -and ($_.SID -notmatch '-500$')}

if ($delete -eq 1) {
    foreach ($profile in $profiles) {
        Write-Host Deleting profile: $($profile.LocalPath) ___ $profile.SID ___ $profile.LastUseTime
        Remove-CimInstance -InputObject $profile -Confirm:$false
    }
} else {
    Write-Host "Running in What-If Mode"
    foreach ($profile in $profiles) {
        Write-Host WHAT-IF profile: $($profile.LocalPath) ___ $profile.SID ___ $profile.LastUseTime
    }
}

# Clear All User Downloads older than 90 Days or 1GB+
$daysOld = 90
$thresholdDate = (Get-Date).AddDays(-$daysOld)
$users = Get-ChildItem -Path "C:\Users\" | Where-Object {$_.Name -notlike "Public" -and $_.Name -notlike "Administrator"}

foreach ($user in $users) {
    $downloadsPath = Join-Path -Path $user.FullName -ChildPath "Downloads"
    if (Test-Path -Path $downloadsPath) {
        Get-ChildItem -Path $downloadsPath -Recurse | Where-Object { $_.LastWriteTime -lt $thresholdDate -or $_.Length -gt 1073741824} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Remove All Users Temp Files 5+ Days Old
$daysOld = 5
$thresholdDate = (Get-Date).AddDays(-$daysOld)
$users = Get-ChildItem -Path "C:\Users\" | Where-Object {$_.Name -notlike "Public" -and $_.Name -notlike "Administrator"}

foreach ($user in $users) {
    $tempPath = Join-Path -Path $user.FullName -ChildPath "AppData\Local\Temp"
    if (Test-Path -Path $tempPath) {
        Get-ChildItem -Path $tempPath -Recurse | Where-Object { $_.LastWriteTime -lt $thresholdDate } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Empty Recycle Bin
Get-ChildItem -Path 'C:\$Recycle.Bin' -Force | Remove-Item -Recurse -ErrorAction SilentlyContinue