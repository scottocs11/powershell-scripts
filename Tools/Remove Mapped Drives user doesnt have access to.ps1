param (
    [bool]$Delete = $true
)

# Get all mapped drives for the current user
$MappedDrives = Get-WmiObject -Class Win32_MappedLogicalDisk

foreach ($drive in $MappedDrives) {
    $DriveLetter = $drive.DeviceID
    $RemotePath = $drive.ProviderName

    Write-Host "`nChecking drive $DriveLetter mapped to $RemotePath..."

    try {
        # Test access by attempting to list contents
        Get-ChildItem -Path $DriveLetter -ErrorAction Stop | Out-Null
        Write-Host "Access OK for $DriveLetter ($RemotePath)" -ForegroundColor Green
    } catch {
        Write-Host "Access DENIED for $DriveLetter ($RemotePath)" -ForegroundColor Red

        if ($Delete) {
            try {
                Write-Host "Attempting to remove $DriveLetter..."
                net use $DriveLetter /delete /y
                Write-Host "Removed $DriveLetter" -ForegroundColor Yellow
            } catch {
                Write-Warning "Failed to remove $DriveLetter"
            }
        }
    }
}
