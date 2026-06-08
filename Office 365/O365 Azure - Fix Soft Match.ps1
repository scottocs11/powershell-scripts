Connect-AzureAD
$user = "first.last"
$userEmail = $user + "@DOMAIN.com"

#Get Immutable ID of Azure AD User
Get-AzureADUser -ObjectId $userEmail | Select-Object ImmutableId

#Get Immutable ID of On-Prem AD User
$guid = (Get-ADUser -Identity $user).ObjectGUID
$immutableID = [System.Convert]::ToBase64String($guid.ToByteArray())

#Set the Immutable ID in Azure AD
Set-AzureADUser -ObjectId $userEmail -ImmutableId $immutableID