# Powershell script to remove group membership from all users in the Disabled OU

# Get all users in the Disabled OU
$Users = Get-ADUser -SearchBase 'OU=Disabled, DC=*domain*, DC=Local' -Filter  'enabled -eq $false'

ForEach($User in $Users)
{
    # Get all groups except Domain Users
    $ADgroups = Get-ADPrincipalGroupMembership -Identity $User | where {$_.Name -ne "Domain Users"}
    
    # If group membership is not null then remove user from group
    if ($ADgroups -ne $null)
    {
		Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $ADgroups -Confirm:$false
    }
}