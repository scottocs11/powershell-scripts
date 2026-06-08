$computer = "name"

qwinsta /server:$computer |
ForEach{

       If($_ -notmatch "SESSIONNAME")
        {
        New-Object -TypeName PSObject -Property `
        @{
         "ID"           = [Int]$_.SubString(41,05).Trim()
         "ComputerName" = $Computer
         "User"         = $_.SubString(19,22).Trim()
         "State"        = $_.SubString(47,08).Trim()
         }
        }
}