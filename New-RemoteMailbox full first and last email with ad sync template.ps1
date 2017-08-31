$Cred = Get-Credential 
$Firstname = Read-Host -Prompt 'Input user''s first name'
$Lastname = Read-Host -Prompt 'Input user''s last name'
$User = $Firstname + ' ' + $Lastname
$UPN = $Firstname.ToLower() + "."  + $Lastname.ToLower() + '@hygiena.com'
$Password  = ConvertTo-SecureString -String "TempPass123" -AsPlainText -Force
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri (servername)/PowerShell/ -Credential $cred -Authentication Kerberos 
Invoke-Command -Session $Session -Scriptblock {New-RemoteMailbox -Name $using:User -Password $using:Password -FirstName $using:Firstname -LastName $using:Lastname -UserPrincipalName $using:UPN -OnPremisesOrganizationalUnit '(AD OU name)' -ResetPasswordOnNextLogon $true}
Invoke-Command -Session $Session2 -Scriptblock {Start-ADSyncSyncCycle} 