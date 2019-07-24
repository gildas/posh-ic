<#
# AUTHOR : Pierrick Lozach
#>

function Remove-ICUser() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Removes a user
.DESCRIPTION
  Removes a user
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUser
  The Interaction Center User
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("User")] [string] $ICUser
  )

  # User exists?
  $userExists = Get-ICUser $ICSession -ICUser $ICUser
  if ([string]::IsNullOrEmpty($userExists)) {
    # User does not exist
<<<<<<< HEAD
    Write-Output "No user found for $ICUser"
    return
=======
    return "User lookup failed for $ICUser , no action taken"
>>>>>>> 8933fa5b451b81199d2ce0dba98e7d3c5c9a2846
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users/$ICUser" -Method Delete -Headers $headers -WebSession $ICSession.webSession #-ErrorAction Stop
  [PSCustomObject] $response
} # }}}2

