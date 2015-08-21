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
#> # }}}3
  [CmdletBinding()]
  Param(
    #[Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("Users", "UserData")] [string] $ICUsers
  )

  <#
  "{tjejejdjf => {username => testcicuser1, password => 1234, extension => 8002}, wjihsdiuhcsd => {username => testcicuser2, password => 5678, extension => 8003 }}"
  #>

  $users = ConvertFrom-Json($ICUsers)

  $users
} # }}}2

#New-ICUsers "{tjejejdjf => {username => testcicuser1, password => 1234, extension => 8002}, wjihsdiuhcsd => {username => testcicuser2, password => 5678, extension => 8003 }}"