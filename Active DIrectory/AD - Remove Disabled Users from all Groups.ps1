# Define the target OU
$OU = "OU=USERS,DC=DOMAIN,DC=com"

# Get all disabled users in the specified OU
$DisabledUsers = Get-ADUser -SearchBase $OU -Filter {Enabled -eq $false} -Properties MemberOf

foreach ($User in $DisabledUsers) {
    $Groups = $User.MemberOf
    foreach ($Group in $Groups) {
        # Remove the user from each group
        Remove-ADGroupMember -Identity $Group -Members $User.DistinguishedName -Confirm:$false #-whatif
        Write-Host "Removed $($User.SamAccountName) from group $Group"
    }
}