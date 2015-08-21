<#
# AUTHOR : Pierrick Lozach
#>

# Documentation {{{3
<#
.SYNOPSIS
  Tests all functionalities of posh-ic
.DESCRIPTION
  Tests all functionalities of posh-ic. Creates users, workgroups and removes them.
#> # }}}3

# Test variables
# --------------
$cicServer   = 'testregfr' # Your CIC server
$cicUser     = 'vagrant'   # CIC username to connect to your CIC server
$cicPassword = '1234'      # User CIC password

$cicTestUser = 'posh-user' # This user should NOT exist on your CIC server. It will be created and deleted by this script for testing purposes.

$cicExistingSkill = 'posh-skill' # This skill should exist on your CIC server. This script will only test its existence and will not modify it.
$cicTestSkill     = 'post-new-skill' # This skill should NOT exist on your CIC server. It will be created and deleted by this script for testing purposes.

$cicExistingWorkgroup = 'TestWorkgroup'  # This workgroup should exist on your CIC server. This script will only test its existence and will not modify it.
$cicTestWorkgroup     = 'posh-workgroup' # This workgroup should NOT exist on your CIC server. It will be created and deleted by this script for testing purposes.

$cicTestIPAProcess = 'Test Process' # This IPA process should exist on your CIC server.

$currentPath= Split-Path((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path

# Update module
# -------------
Remove-Module Posh-IC
Import-Module "$($currentPath)\..\lib\Posh-IC.psm1"

##################
# Connect to CIC #
##################

$cic = New-ICSession -ComputerName $cicServer -User $cicUser -Password $cicPassword

#########
# Users #
#########

# Get all users
Get-ICUsers $cic

# Gets a user
Get-ICUser $cic -User $cicUser

# Test creating a new user
New-ICUser $cic -User $cicTestUser
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with a password
New-ICUser $cic -User $cicTestUser -Password '12345'
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with an extension
New-ICUser $cic -User $cicTestUser -Extension '8001'
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with licenses
New-ICUser $cic -User $cicTestUser -ClientAccess $true -MediaLevel 2 -LicenseActive $true
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with additional licenses
New-ICUser $cic -User $cicTestUser -HasClientAccess $true -MediaLevel 3 -LicenseActive $true -AdditionalLicenses @("*")
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with two specific additional licenses
New-ICUser $cic -User $cicTestUser -HasClientAccess $true -MediaLevel 3 -LicenseActive $true -AdditionalLicenses @("I3_ACCESS_DIALER_ADDON", "I3_ACCESS_FEEDBACK")
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with a domain user
New-ICUser $cic -User $cicTestUser -NTDomainUser $cicUser
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with a preferred language
New-ICUser $cic -User $cicTestUser -PreferredLanguage "fr"
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with roles
New-ICUser $cic -User $cicTestUser -Roles @("Administrator", "Supervisor")
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with all security rights
New-ICUser $cic -User $cicTestUser -SecurityRights "*" # Only All (*) security rights are supported for now
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with all access rights
New-ICUser $cic -User $cicTestUser -AccessRights "*" # Only All (*) access rights are supported for now
Remove-ICUser $cic -User $cicTestUser

# Test creating a new user with all administrative rights
New-ICUser $cic -User $cicTestUser -AdministrativeRights "*" # Only All (*) administrative rights are supported for now
Remove-ICUser $cic -User $cicTestUser

# Test creating a new God user
New-ICUser $cic -User $cicTestUser -SecurityRights "*" -AccessRights "*" -AdministrativeRights "*" # Only All (*) administrative rights are supported for now
Remove-ICUser $cic -User $cicTestUser

##########
# Skills #
##########

# Get all skills
Get-ICSkills $cic

# Gets a skill
Get-ICSkill $cic -Skill $cicExistingSkill

# Creates a new skill
New-ICSkill $cic -Skill $cicTestSkill

# Remove test skill
Remove-ICSkill $cic -Skill $cicTestSkill

##############
# Workgroups #
##############

# Get all workgroups
Get-ICWorkgroups $cic

# Get Workgroup
Get-ICWorkgroup $cic -Workgroup $cicExistingWorkgroup

# Create a new workgroup with members
New-ICUser $cic -User 'posh-ictestuser1'
New-ICUser $cic -User 'posh-ictestuser2'
New-ICUser $cic -User 'posh-ictestuser3'

New-ICWorkgroup $cic -Workgroup $cicTestWorkgroup -Extension '9010' -Members @('posh-ictestuser1', 'posh-ictestuser2', 'posh-ictestuser3')

# Remove test workgroup
Remove-ICWorkgroup $cic -Workgroup $cicTestWorkgroup

# Remove test users
Remove-ICUser $cic -User 'posh-ictestuser1'
Remove-ICUser $cic -User 'posh-ictestuser2'
Remove-ICUser $cic -User 'posh-ictestuser3'

#######
# IPA #
#######
<# !! Getting 403 (Forbidden) !! #>
<#Get-IPAProcesses $cic#> 
<#Get-IPAProcess $cic $cicTestIPAProcess#>
<#Start-IPAProcess $cic -DefinitionId $cicTestIPAProcess#>

<# This works but these need to be executed directly on the CIC server and are provided here as examples #>
<# Import-IPAProcess $cic -Password '1234' -Path "C:\Users\vagrant\Desktop\Exports\Test Process-2.IPAExport" #>
<# Export-IPAProcess $cic -Password '1234' -Path "C:\Users\Vagrant\Desktop\Exports\" #>

######################
# Disconnect Session #
######################

Remove-ICSession $cic