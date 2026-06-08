do {
    $Hostname = Read-Host -Prompt 'LAPS: Computer Name'
    try {
        $pass = Get-LapsADPassword $Hostname -AsPlainText -ErrorAction Stop | Select-Object -ExpandProperty Password
    }
    catch {
        if ($error -like 'Failed to find*') {
            Write-Host $error
            Write-Host ''
        }
    }
    if (!$error) {
        Set-Clipboard $pass
        $pass2 = $pass.insert(3,' ')
        $pass2 = $pass2.insert(7,' ')
        $pass2 = $pass2.insert(11,' ')
        $pass2 = $pass2.insert(15,' ')
        Write-Host $pass2 -ForegroundColor Yellow
        Write-Host "Password copied to clipboard. Ignore spaces in displayed password."
        Write-Host ''
    }
    $error.clear()
 }
 until ($Hostname -eq 'q')