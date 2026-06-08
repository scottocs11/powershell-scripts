# Source and Target OU distinguished names
$SourceOU = "OU=RootOU,DC=YourDomain,DC=com"
$TargetOU = "OU=DisabledUsersArchive,DC=YourDomain,DC=com"

# Get all disabled users recursively within the source OU
$DisabledUsers = Get-ADUser -SearchBase $SourceOU -SearchScope Subtree -Filter {Enabled -eq $false}

foreach ($User in $DisabledUsers) {
    # Move the user to the target OU
    Move-ADObject -Identity $User.DistinguishedName -TargetPath $TargetOU
    Write-Host "Moved $($User.SamAccountName) to $TargetOU"
}