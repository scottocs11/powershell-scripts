$Path = "$PSScriptRoot\AD-UserLastLogin.csv"
Get-ADUser -Filter {enabled -eq $true} -SearchBase "OU=Users,DC=DOMAIN,DC=COM" -Properties LastLogonTimeStamp,givenName,sn,mail,whenCreated | 
  
Select-Object Name,givenName,sn,mail,whenCreated,@{Name="Last Login"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh')}} | Export-Csv -Path $Path –notypeinformation