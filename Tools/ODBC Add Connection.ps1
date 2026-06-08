$odbcname="name"
$sqlserver="server" #\Instance"
$sqldb="db"
$OdbcDriver = Get-OdbcDriver -Name 'SQL Server' -Platform 32-bit
 
Add-OdbcDsn -Name $odbcname -DriverName $OdbcDriver.Name -Platform 32-bit -DsnType System -SetPropertyValue @("Server=$sqlserver", "Trusted_Connection=Yes","Database=$sqldb")