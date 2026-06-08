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
        $Email = "$SamAccountName@mktalliance.com"
        $Password = "Marketing$Month$Year"

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

}

# Run the function
New-MKTADUser
