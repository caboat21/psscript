# Powershell script to move disabled users to Disabled OU, remove group membership from all users in the Disabled OU, and hide disabled users from Exchange address lists

Import-Module ActiveDirectory

# Distinguished name of Disabled OU
$DisabledOU = 'OU=Disabled, DC=*domain*, DC=Local'

# Disabled users in the Disabled OU
$Users = Get-ADUser -SearchBase $DisabledOU -Filter 'enabled -eq $false'

# List of OUs to check for disabled user accounts
$SearchOUs = '(OU=Users,OU=*Root*,DC=*domain*,DC=Local)','(OU=Users,OU=*Root*,DC=*domain*,DC=Local)','(OU=Users,OU=*Root*,DC=*domain*,DC=Local)'

$SearchOUs | 
# Search each OU for disabled user accounts
ForEach-Object 
{
    Search-ADAccount -AccountDisabled -UsersOnly -SearchBase $_ | 
    Select Name,DistinguishedName | 
    # Move each disabled account into Disabled OU
    ForEach-Object {
        Move-ADObject -Identity $_.DistinguishedName -TargetPath $DisabledOU
    }
}

ForEach($User in $Users)
{
    # Get all groups except Domain Users
    $ADgroups = Get-ADPrincipalGroupMembership -Identity $User | where {$_.Name -ne "Domain Users"}
    
    # If user is in group(s) then remove user from group(s)
    if ($ADgroups -ne $null)
    {
		Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $ADgroups -Confirm:$false
    }
}

# Find disabled users that do not have the msExchHideFromAddressLists property and add it
Get-ADUser -SearchBase $DisabledOU -Filter {(mail -like "*") -and(enabled -eq $false) -and(msExchHideFromAddressLists -notlike "*")} | Set-ADUser -Add @{msExchHideFromAddressLists="TRUE"}

# Find disabled users that have the msExchHideFromAddressLists property set to false and change to true
Get-ADUser -SearchBase $DisabledOU -Filter {(mail -like "*") -and(enabled -eq $false) -and(msExchHideFromAddressLists -eq $false)} | Set-ADUser -Replace @{msExchHideFromAddressLists="TRUE"}