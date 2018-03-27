Import-Module ActiveDirectory
Search-ADAccount  -SearchBase "OU=USA,DC=DrMartens,DC=local" â€“PasswordNeverExpires |
Select -Property Name,DistinguishedName |
Export-CSV "C:\\Temp\PasswordNeverExpireADUsers.csv" -NoTypeInformation -Encoding UTF8
