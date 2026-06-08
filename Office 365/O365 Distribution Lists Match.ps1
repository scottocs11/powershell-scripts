$Delete = 0 # 0 To Test, 1 to Sync

$DistList = "List Name"

$Date = (Get-Date).tostring("MMddyyyy")

if ($Connected -ne 1) {
    Connect-ExchangeOnline
    $Connected = 1}

function delete {
    Get-DistributionGroupMember -Identity $DistList | Select Name, PrimarySMTPAddress | Export-Csv "$PSScriptRoot\O365 Export $DistList $Date.csv" -NoTypeInformation -Encoding UTF8
    $csvImport = Import-Csv "$PSScriptRoot\O365 Import Match.csv"
    $csvExport = Import-Csv "$PSScriptRoot\O365 Export $DistList $Date.csv"
    foreach ($value in $csvExport) {
        $email = $value.PrimarySmtpAddress
        $name = $value.Name
        if ($email -in $csvImport.Email) {
            Write-Host $site ": Exists :" $email
        }

        else {
            If ($Delete -eq 0) {
                Write-Host $site ": NOT Exists :" $email }
            If ($Delete -eq 1) {
                Write-Host $site ": NOT Exists :" $email "...Deleting"
                try { Remove-DistributionGroupMember -Identity $DistList -Member $email -ErrorAction Stop -Confirm:$false }
                catch { Write-Host $site ": INVALID :" $email }
                }
        }
    }
    Get-DistributionGroupMember -Identity $DistList | Select Name, PrimarySMTPAddress | Export-Csv "$PSScriptRoot\O365 Export $DistList Delete $Date-New.csv" -NoTypeInformation -Encoding UTF8
}

#$DistList = $site + "List"
#$DistList = Get-Variable $DistList -ValueOnly
delete