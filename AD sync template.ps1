 $UserCredential = Get-Credential
Enter-PSSession -computername "name of computer"

Invoke-Command {start-adsyncsynccycle}