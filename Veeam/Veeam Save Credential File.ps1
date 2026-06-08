$encPassFileName = "$PSScriptRoot\cred.cred"
(Get-Credential).Password | ConvertFrom-SecureString | Set-Content $encPassFileName