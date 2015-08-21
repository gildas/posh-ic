<#
# AUTHOR : Pierrick Lozach
#>

function New-ICUsers() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Creates new IC users
.DESCRIPTION
  Creates new IC users. If passwords are ommitted, default value is '1234'
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUsers
  Hashtable of user data, including usernames, passwords and extensions
  Sample:
  {"randomstring":{"username":"testcicuser1","password":"1234","extension":"8002"}, "anotherrandomstring":{"username":"testcicuser2","password":"5678","extension":"8003"}}
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("Users", "UserData")] [string] $ICUsers
  )

  $users = ConvertFrom-Json($ICUsers)

  $users | Get-Member -MemberType NoteProperty | ForEach-Object { 
    $currentUser = $users."$($_.Name)"
    New-ICUser $ICSession -ICUser $currentUser.username -Password $currentUser.password -Extension $currentUser.extension
  }

} # }}}2