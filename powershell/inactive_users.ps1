Param (
[string]$Path = "c:\temp",
[string]$SearchBase = "OU=XXX,DC=XXX,DC=XXX",
[int]$Age = 2,
[string]$From = "email@contoso.comm",
[string]$To = "email@contoso.com",
[string]$SMTPServer = "127.0.0.1"
)

Clear-Host
$Result = @()

#region Determine MaxPasswordAge
#Determine MaxPasswordAge
$maxPasswordAgeTimeSpan = $null
$dfl = (get-addomain).DomainMode
$maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
If ($maxPasswordAgeTimeSpan -eq $null -or $maxPasswordAgeTimeSpan.TotalMilliseconds -eq 0)
{Write-Host "MaxPasswordAge is not set for the domain or is set to zero!"
Write-Host "So no password expiration's possible."
Exit
}
#endregion

$Users = Get-ADUser -Filter * -SearchBase $SearchBase -SearchScope Subtree -Properties GivenName,sn,PasswordExpired,PasswordLastSet,PasswordneverExpires,LastLogonDate
ForEach ($User in $Users)
{If ($User.PasswordNeverExpires -or $User.PasswordLastSet -eq $null)
{Continue
}
If ($dfl -ge 3)
{## Greater than Windows2008 domain functional level
$accountFGPP = $null
$accountFGPP = Get-ADUserResultantPasswordPolicy $User
    If ($accountFGPP -ne $null)
{$ResultPasswordAgeTimeSpan = $accountFGPP.MaxPasswordAge
    }
Else
{$ResultPasswordAgeTimeSpan = $maxPasswordAgeTimeSpan
    }
}
Else
{$ResultPasswordAgeTimeSpan = $maxPasswordAgeTimeSpan
}
$Expiration = $User.PasswordLastSet + $ResultPasswordAgeTimeSpan
If ((New-TimeSpan -Start (Get-Date) -End $Expiration).Days -le $Age)
{$Result += New-Object PSObject -Property @{
'Last Name' = $User.sn
'First Name' = $User.GivenName
UserName = $User.SamAccountName
'Expiration Date' = $Expiration
'Last Logon Date' = $User.LastLogonDate
State = If ($User.Enabled) { "" } Else { "Disabled" }
}
}
}
$Result = $Result | Select-Object 'Last Name','First Name',UserName,'Expiration Date','Last Logon Date',State | Sort-Object 'Expiration Date','Last Name'

#Produce a CSV
$ExportDate = Get-Date -f "yyyy-MM-dd"
$Result | Export-Csv $path\ExpiredReport-$ExportDate.csv -NoTypeInformation

# #Send HTML Email
# $Header = @"
# <style>
# TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
# TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
# TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
# </style>
# "@
# $splat = @{
# From = $From
# To = $To
# SMTPServer = $SMTPServer
# Subject = "SLC Password Expiration Report"
# }
# $Body = $Result | ConvertTo-Html -Head $Header | Out-String
# Send-MailMessage @splat -Body $Body -BodyAsHTML -Attachments $Path\SLCExpiredReport-$ExportDate.csv
