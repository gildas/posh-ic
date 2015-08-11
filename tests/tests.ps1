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

$cicTestUser1    = 'posh-user1' # This user should NOT exist on your CIC server. It will be created and deleted by this script for testing purposes.
$cicTestUser2    = 'posh-user2' # This user should NOT exist on your CIC server. It will be created and deleted by this script for testing purposes.
$cicTestUser3    = 'posh-user3' # This user should NOT exist on your CIC server. It will be created and deleted by this script for testing purposes.

$cicExistingWorkgroup    = 'TestWorkgroup'  # This workgroup should exist on your CIC server. This script will only test its existence and will not modify it.
$cicTestWorkgroup        = 'posh-workgroup' # This workgroup should NOT exist on your CIC server. It will be created and deleted by this script for testing purposes.

# Update module
# -------------
Remove-Module Posh-IC
Import-Module ..\lib\Posh-IC.psm1

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

# Create a new user
New-ICUser $cic -User $cicTestUser1 -Password '123456' -Extension '8001'

# Create a new user w/o the extension
New-ICUser $cic -User $cicTestUser2 -Password '12345'

# Create a new user w/o the extension and the password
New-ICUser $cic -User $cicTestUser3

##############
# Workgroups #
##############

# Get all workgroups
Get-ICWorkgroups $cic

# Get Workgroup
Get-ICWorkgroup $cic -Workgroup $cicExistingWorkgroup

# Create a new workgroup
New-ICWorkgroup $cic -Workgroup $cicTestWorkgroup -Extension '9010' -Members @($cicTestUser1, $cicTestUser2, $cicTestUser3)

# Remove it
Remove-ICWorkgroup $cic -Workgroup $cicTestWorkgroup

###########
# Cleanup #
###########

# Remove test users
Remove-ICUser $cic -User $cicTestUser1
Remove-ICUser $cic -User $cicTestUser2
Remove-ICUser $cic -User $cicTestUser3

######################
# Disconnect Session #
######################

Remove-ICSession $cic