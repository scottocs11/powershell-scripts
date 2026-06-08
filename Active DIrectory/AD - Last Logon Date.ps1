param (
    [string]$Username = $(Read-Host "Enter the AD username")
)

try {
    $user = Get-ADUser -Identity $Username -Properties LastLogonDate -ErrorAction Stop
    if ($user.LastLogonDate) {
        Write-Host "User '$Username' last logged on at: $($user.LastLogonDate)" -ForegroundColor Green
    } else {
        Write-Host "User '$Username' has never logged on." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error: Could not find user '$Username' in Active Directory." -ForegroundColor Red
}
