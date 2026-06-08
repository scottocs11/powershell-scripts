Import-Module ActiveDirectory

function Show-Menu {
    #param (
    #    [string]$Title = 'AD Toolkit'
    #)
    #Clear-Host
    #Write-Host "========= $Title ========="
    Write-Host "1: Dameware into PC using LAPS"
    Write-Host "2: RDP Into PC using LAPS"
    Write-Host "3: Copy LAPS Password"
    Write-Host "4: Close File on File Server"
    Write-Host "5: New User"
    Write-Host "6: User Info"
    Write-Host "7: "
    Write-Host "8: "
    Write-Host "9: Repeat Last Function"
#    Write-Host "3: Open C$ Share"
#    Write-Host "Q: Quit"
}

function Dameware {
    $Hostname = Read-Host -Prompt 'PC to Dameware into'
    GetPassword $Hostname
    Start-Process "C:\Program Files\SolarWinds\Dameware Mini Remote Control 9.0\DWRCC.exe" -ArgumentList "-c: -h: -m:$Hostname -p:$password -u:Administrator -d:. -x: -md:"
    Set-Variable -Name command -Value "Start-Process 'C:\Program Files\SolarWinds\Dameware Mini Remote Control 9.0\DWRCC.exe' -ArgumentList '-c: -h: -m:$Hostname -p:$password -u:Administrator -d:. -x: -md:'" -Scope global
}

function RDP {
    $Hostname = Read-Host -Prompt 'PC to RDP Into'
    GetPassword $Hostname
    $User = $Hostname + "\Administrator"
    cmdkey /generic:$Hostname /user:$User /pass:$Password
    mstsc /v:$Hostname /w:1880 /h:900
    Set-Variable -Name command -Value "mstsc /v:$Hostname /w:1880 /h:900" -Scope global
}

function Laps {
    $Hostname = Read-Host -Prompt 'LAPS: Computer Name'
    GetPassword $Hostname
    Set-Variable -Name command -Value "GetPassword $Hostname" -Scope global
}

function Repeat {
    $command = [scriptblock]::Create($command)
    &$command
}

function GetPassword($Hostname) {
    $repeat = $true

    do {
        try {
            $pass = Get-LapsADPassword $Hostname -AsPlainText -ErrorAction Stop | Select-Object -ExpandProperty Password
        }
        catch {
            Write-Host "Failed to retrieve password for $Hostname. Please check the name and try again." -ForegroundColor Red
            $Hostname = Read-Host -Prompt "Enter computer name"
            continue
        }

        if ($pass) {
            Set-Variable -Name Password -Value $pass -Scope global
            Set-Clipboard $pass
            $pass2 = $pass.insert(3,' ').insert(7,' ').insert(11,' ').insert(15,' ')
            Write-Host $pass2 -ForegroundColor Yellow
            Write-Host ''
            $repeat = $false
        }
    } while ($repeat)
}

function CloseFile {
    Write-Host "1: FILESERVER1"
    Write-Host "2: FILESERVER2"
    Write-Host "3: FILESERVER3"
    Write-Host "C: Cancel"
    Write-Host "Or type server name"

    $serverInput = Read-Host -Prompt "Server"

    if ($serverInput -eq 'C') {
        Write-Host "Script cancelled by user." -ForegroundColor Yellow
        return
    }

    switch ($serverInput) {
        "1" { $server = "FILESERVER1" }
        "2" { $server = "FILESERVER2" }
        "3" { $server = "FILESERVER3" }
        default { $server = $serverInput }
    }

    # Verify server exists
    if (-not (Test-Connection -ComputerName $server -Count 1 -Quiet)) {
        Write-Host "Server '$server' not reachable. Please check the name and try again." -ForegroundColor Red
        return
    }

    do {
        $file = Read-Host -Prompt "Filename"
        $filePattern = "*$file*"

        Write-Host "Searching $server for $filePattern ..."
        $files = Get-SmbOpenFile -CimSession $server | Where-Object { $_.Path -like $filePattern }

        if (-not $files) {
            Write-Host "No files found matching '$filePattern' on server '$server'."
            $retry = Read-Host -Prompt "Retry search with a different filename? y/n"
        }
    } while (-not $files -and $retry -eq "y")

    foreach ($entry in $files) {
        $path = $entry.Path
        $fileid = $entry.FileId
        $PathShort = ([System.IO.Path]::GetFileName($path))
        $user = $entry.ClientUserName
        $response = Read-Host -Prompt "$PathShort is open by $user. Close it? y/n"

        if ($response -eq "y") {
            Write-Host "Closing $PathShort..."
            Invoke-Command -ComputerName $server -ScriptBlock {
                param ($fid)
                Close-SmbOpenFile -FileId $fid -Force
            } -ArgumentList $fileid
        } else {
            Write-Host "Skipping $PathShort..."
        }
    }
    Set-Variable -Name command -Value "CloseFile" -Scope global
}

function ADUserInfo {
    # Prompt for username in "First Last" format
    $FullName = Read-Host "Enter the AD username. Ex: First Last"
    $FullName = $FullName.Trim()

    # Convert to lowercase and replace space with dot
    $Username = ($FullName -replace '\s+', '.').ToLower()

    try {
        # Search for the user by SamAccountName with additional properties
        $user = Get-ADUser -Filter "SamAccountName -eq '$Username'" -Properties `
            LastLogonDate, msDS-UserPasswordExpiryTimeComputed, PasswordNeverExpires, `
            Enabled, LockedOut, PasswordLastSet, BadLogonCount

        if ($null -eq $user) {
            Write-Host "Error: Could not find user '$Username' in Active Directory." -ForegroundColor Red
            return
        }

        # Output last logon
        if ($user.LastLogonDate) {
            Write-Host "$Username last logged on at: $($user.LastLogonDate)" -ForegroundColor Green
        } else {
            Write-Host "$Username has never logged on." -ForegroundColor Yellow
        }

        # Account status
        if ($user.Enabled) {
            Write-Host "$Username account is currently: Enabled" -ForegroundColor Green
        } else {
            Write-Host "$Username account is currently: Disabled" -ForegroundColor Yellow
        }

        # Password last set
        if ($user.PasswordLastSet) {
            Write-Host "$Username password was last set on: $($user.PasswordLastSet)" -ForegroundColor Green
        } else {
            Write-Host "Password last set date is not available." -ForegroundColor Yellow
        }

        # Failed logon attempts
        Write-Host "$Username has $($user.BadLogonCount) failed logon attempt(s)." -ForegroundColor Green

        # Password expiration status
        if ($user.PasswordNeverExpires) {
            Write-Host "$Username's password is set to never expire." -ForegroundColor Red
        } else {
            $expiryRaw = $user.'msDS-UserPasswordExpiryTimeComputed'
            if ($expiryRaw -and $expiryRaw -gt 0) {
                $expiryDate = [datetime]::FromFileTime($expiryRaw)
                if ($expiryDate -lt (Get-Date)) {
                    Write-Host "$Username password is expired." -ForegroundColor Red
                } else {
                    Write-Host "$Username password is not expired." -ForegroundColor Green
                }
            } else {
                Write-Host "Password expiration status for user '$Username' is not available." -ForegroundColor Yellow
            }
        }


    } catch {
        Write-Host "Unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }

    Set-Variable -Name command -Value "ADUserInfo" -Scope global
}

function NewUser {
    $Year = (Get-Date).Year
    $Month = (Get-Culture).DateTimeFormat.GetMonthName((Get-Date).Month)

    # Prompt for new user's full name in a loop until valid and unique
    do {
        $FullName = Read-Host "Enter the new user's full name (First Last)"
        $FullName = $FullName.Trim()
        $NameParts = $FullName -split ' '

        if ($NameParts.Count -ne 2) {
            Write-Host "Invalid format. Please enter in 'First Last' format." -ForegroundColor Red
            continue
        }

        $FirstName = ($NameParts[0].Substring(0,1).ToUpper()) + $NameParts[0].Substring(1).ToLower()
        $LastName = ($NameParts[1].Substring(0,1).ToUpper()) + $NameParts[1].Substring(1).ToLower()
        $SamAccountName = "$($FirstName.ToLower()).$($LastName.ToLower())"

        # Check for existing user with same SamAccountName
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"
        if ($existingUser) {
            Write-Host "A user with username '$SamAccountName' already exists: $($existingUser.Name)" -ForegroundColor Yellow
            continue
        }

        # ✅ Set these only after confirming the name is valid and unique
        $DisplayName = "$FirstName $LastName"
        $Email = "$SamAccountName@DOMAIN.com" #CHANGE
        $Password = "COMPANY$Month$Year"

        $validName = $true
    } while (-not $validName)

    # Prompt for existing user to copy using "First Last" format
    do {
        $TemplateFullName = Read-Host "Enter the name of an existing user to copy (First Last)"
        $TemplateFullName = $TemplateFullName.Trim()
        $TemplateParts = $TemplateFullName -split ' '

        if ($TemplateParts.Count -ne 2) {
            Write-Host "Invalid format. Please enter in 'First Last' format." -ForegroundColor Red
            continue
        }

        $TemplateFirst = $TemplateParts[0]
        $TemplateLast = $TemplateParts[1]
        $TemplateSam = "$($TemplateFirst.ToLower()).$($TemplateLast.ToLower())"

        try {
            $templateUser = Get-ADUser -Identity $TemplateSam -Properties *
        } catch {
            $templateUser = $null
        }

        if ($null -eq $templateUser) {
            Write-Host "User '$TemplateSam' not found. Try again." -ForegroundColor Red
        }


    } while ($null -eq $templateUser)

    # Confirm template user
    # Extract OU parts from the DN
    $ouParts = ($templateUser.DistinguishedName -split ',') | Where-Object { $_ -like 'OU=*' }

    # Get the top two sub-OUs (from left to right)
    if ($ouParts.Count -ge 2) {
        $subOU = ($ouParts[1..0] | ForEach-Object { ($_ -split '=')[1] }) -join ' -> '
        Write-Host "$($templateUser.Name) found in $subOU" -ForegroundColor Cyan
    } else {
        Write-Host "$($templateUser.Name) found in unknown OU structure." -ForegroundColor Yellow
    }

    $confirm = Read-Host "Use this user as template? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        return
    }

    # Create new user
    Write-Host ""
    try {
        New-ADUser `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $Email `
            -Name $DisplayName `
            -GivenName $FirstName `
            -Surname $LastName `
            -DisplayName $DisplayName `
            -EmailAddress $Email `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true `
            -PasswordNeverExpires $false `
            -ChangePasswordAtLogon $false `
            -Path $templateUser.DistinguishedName.Substring($templateUser.DistinguishedName.IndexOf("OU=")) `
            -Office $templateUser.Office `
            -StreetAddress $templateUser.StreetAddress `
            -City $templateUser.City `
            -State $templateUser.State `
            -PostalCode $templateUser.PostalCode `
            -Department $templateUser.Department `
            -Company $templateUser.Company

        Write-Host "User '$DisplayName' created successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error creating user: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    # Copy group memberships
    $groups = Get-ADUser $templateUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf
    foreach ($groupDN in $groups) {
        $group = Get-ADGroup -Identity $groupDN
        if ($group.Name -ne 'VPN-Users') {
            try {
                Add-ADGroupMember -Identity $group.Name -Members $SamAccountName
            } catch {
                Write-Host "Failed to add to group '$($group.Name)': $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }

    # Display new user info
    Write-Host "Username: $SamAccountName" -ForegroundColor Cyan
    Write-Host "Password: $Password" -ForegroundColor Cyan
    Write-Host "Email: $Email"
    Set-Variable -Name command -Value "ADNewUser" -Scope global
}

#Menu
do
 {
    Show-Menu
    $selection = Read-Host "Option"
    Write-Host ''
    switch ($selection)
    {
    '1' {
        Dameware
    } '2' {
        RDP
    } '3' {
        LAPS
    } '4' {
        CloseFile
    } '5' {
        NewUser
    } '6' {
        ADUserInfo
    } '7' {
        #
    } '8' {
        #
    } '9' {
        Repeat
    }
    }
    Write-Host ''
 }
 until ($selection -eq 'q')