<#
# AUTHOR : Pierrick Lozach
#>

function New-ICConfigurationId() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Creates a new ICWS ConfigurationId complex object
.DESCRIPTION
  Creates a new ICWS ConfigurationId complex object. This is used when creating new users or workgroups.
.PARAMETER ItemId
  The Interaction Center Item Identifier
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [string] $ItemId
  )

  # Will add displayName and uri later on...
  $hash = @{}
  $hash.Add("id", $ItemId)
  return $hash

} # }}}2

