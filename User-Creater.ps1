#Get template user
$TemplateUser = Read-Host "Enter template user"
$TemplateUserObj = Get-ADUser -Identity $TemplateUser

#Get template user OU and group membership
$TemplateUserOUArray = $TemplateUserObj.DistinguishedName.Split(",")[1..($TemplateUserObj.DistinguishedName.Length - 1)]
$TemplateUserGroupsArray = (Get-ADPrincipalGroupMembership $TemplateUserObj).name
Write-Output $TemplateUserGroupsArray

#Get new user
$NewUser = Read-Host "Enter new user"

#Formats new user username
$NewUserFI = $NewUser.Split(" ")[0][0]
$NewUserLN = $NewUser.Split(" ")[1]
$NewUserSAM = $NewUserFI + $NewUserLN


$TemplateUserOU = $TemplateUserOUArray -join ","

#Instiates new user object
New-ADUser -Name "$NewUser" -SamAccountName "$NewUserSAM" -AccountPassword (Read-Host -AsSecureString "PWD") -Path "$TemplateUserOU"
Enable-ADAccount -Identity "$NewUserSAM"

#Adds new user to correct groups
foreach ($Group in $TemplateUserGroupsArray)
{
    Write-Output $Group
    Add-ADGroupMember -Identity "$Group" -Members $NewUserSAM
}

#Attempts to starts AD delta sync
try
{
    Get-Service -Name "adsync"
    Start-ADSyncSyncCycle -PolicyType Delta
}
catch
{
    Write-Ouput "Sucks to suck"
}