$LocalExeFile = "C:\ProgramData\DesktopInfo\DesktopInfo.exe"
$ServerExeFile = "\\shared\DesktopInfo\DesktopInfo.exe"

$LocalFolder = "C:\ProgramData\DesktopInfo\"
$ServerFolder = "\\shared\DesktopInfo\"
$LocalC = "C:\ProgramData\"

$LocalSettingsFile = $LocalFolder + "desktopinfo.ini"
$ServerSettingsFile = $ServerFolder + "desktopinfo.ini"

$LocalTicketFile = $LocalFolder + "Support Ticket.oft"
$ServerTicketFile= $ServerFolder + "Support Ticket.oft"

$Updated = 0

#Kill DesktopInfo
Stop-Process -name DesktopInfo -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Stop-Process -name DesktopInfo -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Stop-Process -name DesktopInfo -Force -ErrorAction SilentlyContinue

#Update
function Update {
    If ($Updated -ne 1) {
        Stop-Process -name DesktopInfo -Force -ErrorAction SilentlyContinue
        Copy-Item $ServerFolder $LocalC -Recurse -Force
        $Updated=1
    }
}

#If local DesktopInfo folder doesn't exist, update
$LocalFolderExists = Test-Path $LocalFolder
If (!$LocalFolderExists) {
    #Write-Host "DesktopInfo Folder Doesn't Exist: Updating..."
    #New-Item -Path $LocalFolder -ItemType Directory
    Update
}

#If local DesktopInfo.exe doesn't exist (for some odd reason), update
$LocalExeFile = $LocalFolder + "DesktopInfo.exe"
$LocalExeFileExists = Test-Path $LocalExeFile -PathType Leaf
If (!$LocalExeFileExists) {
    #Write-Host "DesktopInfo.exe Doesn't Exist: Updating..."
    Update
}

#Compare Local DesktopInfo.exe
$LocalExeVersion = Get-ItemProperty $LocalExeFile | select -expand VersionInfo | select -expand ProductVersion
$ServerExeVersion = Get-ItemProperty $ServerExeFile | select -expand VersionInfo | select -expand ProductVersion

if ($LocalExeVersion -gt $ServerExeVersion) {
    #Write-Host "Local DesktopInfo.exe is newer $LocalExeVersion than server. $ServerExeVersion"
} elseif ($version1 -lt $version2) {
    #Write-Host "Local DesktopInfo.exe $LocalExeVersion is older than server $ServerExeVersion...UPDATING"
    Update
} else {
    #Write-Host "Local and Server DesktopInfo.exe are the same version $LocalExeVersion"
}

#Compare Local Desktopinfo.ini
$LocalSettings = Get-Content $LocalSettingsFile
$ServerSettings = Get-Content $ServerSettingsFile
$CompareSettings = Compare-Object -ReferenceObject $LocalSettings -DifferenceObject $ServerSettings

if ($CompareSettings) {
    #Write-Host "Differences found in DesktopInfo.ini... Updating"
    Update
} else {
    #Write-Host "Desktopinfo.ini files are identical."
}

#Compare Local Support Ticket.oft
$LocalTicket = Get-Content $LocalTicketFile
$ServerTicket = Get-Content $ServerTicketFile
$CompareTicket = Compare-Object -ReferenceObject $LocalSettings -DifferenceObject $ServerSettings

if ($CompareTicket) {
    #Write-Host "Differences found in Support Ticket.oft ...Updating"
    Update
} else {
    #Write-Host "Support Ticket.oft files are identical."
}

#Reset
$Updated = 0

Start-Sleep -Seconds 10
Start-Process -FilePath $LocalExeFile