<#
# AUTHOR : Pierrick Lozach
#>

function New-ICWorkgroups() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Creates new IC workgroups
.DESCRIPTION
  Creates new IC workgroups.
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICWorkgroups
  Hashtable of user data, including usernames and extensions
  Sample:
  {"randomstring":{"workgroupname":"testcicworkgroup1","extension":"6001"}, "anotherrandomstring":{"workgroupname":"testcicworkgroup2","extension":"6002"}}
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("Workgroups", "WorkgroupData")] [string] $ICWorkgroups
  )

  $workgroups = ConvertFrom-Json($ICWorkgroups)

  $workgroups | Get-Member -MemberType NoteProperty | ForEach-Object { 
    $currentWorkgroup = $workgroups."$($_.Name)"
    New-ICWorkgroup $ICSession -ICWorkgroup $currentWorkgroup.workgroupname -Extension $currentWorkgroup.extension
  }

} # }}}2