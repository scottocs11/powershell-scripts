$OUs = "OU=Workstations,DC=DOMAIN,DC=com"

$Result = ForEach($OU in $OUs){
    Get-ADComputer -Filter * -SearchBase $OU -SearchScope OneLevel -Properties ms-Mcs-AdmPwd | Select-Object Name,ms-Mcs-AdmPwd #| Sort-Object Name
}
$Result | Export-Csv -path "$PSScriptRoot\LAPS Workstations.csv" -NoTypeInformation
#$Result | Export-Csv -path "$PSScriptRoot\LAPS-Workstations-$((Get-Date).ToString("MM-dd-yyyy")).csv" -NoTypeInformation