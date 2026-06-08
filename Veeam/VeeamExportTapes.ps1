$tapes = Get-VBRTapeMedium | where {($_.Location.type -eq "Slot") -and ($_.expirationdate -ne $null)}
foreach ($tape in $tapes) {
    Write-Host Exporting $tape.barcode
    Export-VBRTapeMedium -Medium $tape
}