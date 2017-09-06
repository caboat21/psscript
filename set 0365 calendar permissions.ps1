$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Add-MailboxFolderPermission -Identity "calender we are trying to access":\calendar -user "User WHO NEEDS ACCESS" -AccessRights Editor 