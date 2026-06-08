#Get TPM Key
$id = ((Get-BitLockerVolume -MountPoint C).KeyProtector | Where-Object { $_.KeyProtectorType -like "*Tpm*" }).KeyProtectorId

#Backup
manage-bde -protectors -adbackup c: -id $id


