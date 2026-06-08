$Computers = Get-ADComputer -Filter * -SearchBase "OU=Servers, DC=DOMAIN, DC=com" -Properties ms-Mcs-AdmPwd | Select-Object Name,ms-Mcs-AdmPwd | Sort-Object Name
$Computers | Export-Csv -path "$PSScriptRoot\LAPS Servers.csv" -NoTypeInformation
#$Computers | Export-Csv -path "$PSScriptRoot\"LAPS Servers-$((Get-Date).ToString("MM-dd-yyyy")).csv" -NoTypeInformation