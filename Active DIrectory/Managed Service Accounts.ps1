#https://www.youtube.com/watch?v=ELfL4AhopRU

$MSAName = "TestService" # Less than 16 characters
$ServerName = "SERVER1"
$MemberName = $ServerName + "$"
$Identity = Get-ADComputer $ServerName
$GMSA_Group = $MSAName + "-Group"
$FQDN = $MSAName + "-gmsa.DOMAIN.com" ###
$Path = "CN=Managed Service Accounts,DC=DOMAIN,DC=com" ###
$PathG = "CN=" + $GMSA_Group + "," + $Path

#1. Create Group
New-ADGroup -Name $GMSA_Group -SamAccountName $GMSA_Group `
            -GroupCategory Security -GroupScope Global -DisplayName $GMSA_Group `
            -Path $Path;

#2. Add computer accounts to group that will make use of GMSA:
Add-ADGroupMember $PathG -Members $MemberName;

#3. Create GROUP MSA
New-ADServiceAccount -name $MSAName -dnshostname $FQDN –PrincipalsAllowedToRetrieveManagedPassword (Get-ADGroup $GMSA_Group) -PassThru


#On Client PC
#Test-ADServiceAccount -Identity $MSAName | Format-List
#Install-ADServiceAccount -Identity $MSAName #Run As Administrator under DR Account
#Change service to service account. No password.

#Remove-ADServiceAccount –identity $MSAName -Confirm:$false;



#List Service Accounts:
#Get-ADServiceAccount -Filter *
#Get-ADServiceAccount -identity $MSAName -properties principalsallowedtoretrievemanagedpassword

#SINGLE PC
#New-ADServiceAccount -name $MSAName -Enabled $true -Description $ServerName -RestrictToSingleComputer

#Associate MSA with PC
#Set-ADServiceAccount -Identity $MSAName -PrincipalsAllowedToRetrieveManagedPassword $ServerName
#Add-ADComputerServiceAccount -Identity $Identity -ServiceAccount AzureADConnect -PassThru