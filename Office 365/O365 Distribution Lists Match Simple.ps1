$Delete = 0 # 0 To Test, 1 to Sync
$Add = 1

$list = "List Name"

$Date = (Get-Date).tostring("MMddyyyy")

if ($Connected -ne 1) {
    Connect-ExchangeOnline
    $Connected = 1}

function match {
    Get-DistributionGroupMember -Identity $list | Select Name, PrimarySMTPAddress | Export-Csv "$PSScriptRoot\O365 Export $list $Date.csv" -NoTypeInformation -Encoding UTF8
    $csvImport = Import-Csv "$PSScriptRoot\O365 Import Match Simple.csv"
    $csvExport = Import-Csv "$PSScriptRoot\O365 Export $list $Date.csv"
    foreach ($value in $csvExport) {
        $email = $value.PrimarySmtpAddress
        $name = $value.Name
        
        #Delete Users not in Import List
        if ($email -in $csvImport.Email) {
            Write-Host $list ": Exists in Import :" $email
        }

        else {
            If ($Delete -eq 0) {
                Write-Host $list ": NOT Exists :" $email "...Would Delete" }
            If ($Delete -eq 1) {
                Write-Host $list ": NOT Exists :" $email "...Deleting"
                try { Remove-DistributionGroupMember -Identity $list -Member $email -ErrorAction Stop -Confirm:$false }
                catch { Write-Host $list ": INVALID :" $email }
                }
        }
    }
        #Add Users not in Existing Export List
    foreach ($value in $csvImport) {
        $email = $value.email
        if ($email -in $csvExport.PrimarySmtpAddress) {
            Write-Host $list ": Exists in O365 :" $email
        }

        else {
            If ($Add -eq 0) {
                Write-Host $list ": NOT Exists :" $email "...Would Add" }
            If ($Add -eq 1) {
                Write-Host $list ": NOT Exists :" $email "...Adding"
                try { Add-DistributionGroupMember -Identity $list -Member $email -ErrorAction Stop }
                catch { Write-Host $site ": INVALID :" $email }
                }
        }
    }
    #Get-DistributionGroupMember -Identity $list | Select Name, PrimarySMTPAddress | Export-Csv "$PSScriptRoot\O365 Export $list Delete $Date-New.csv" -NoTypeInformation -Encoding UTF8
}


match