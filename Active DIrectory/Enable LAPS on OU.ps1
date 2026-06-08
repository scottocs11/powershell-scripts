$OU = "Servers"
#Import-Module AdmPwd.PS #Run one-time
#Update-AdmPwdADSchema #Run one-time
Set-AdmPwdComputerSelfPermission -Identity $OU
Set-AdmPwdReadPasswordPermission -Identity $OU –AllowedPrincipals "LAPS_READ"
Set-AdmPwdResetPasswordPermission -Identity $OU –AllowedPrincipals "LAPS_RESET"