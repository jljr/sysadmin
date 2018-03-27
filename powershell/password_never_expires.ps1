Import-Module ActiveDirectory
Search-ADAccount  -SearchBase "OU=XXX,DC=XXX,DC=XXX" -PasswordNeverExpires |
Select -Property Name,DistinguishedName |
Export-CSV "C:\\Temp\PasswordNeverExpireADUsers.csv" -NoTypeInformation -Encoding UTF8
