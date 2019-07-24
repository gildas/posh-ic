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
    return "User lookup failed for $ICUser , no action taken"
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users/$ICUser" -Method Delete -Headers $headers -WebSession $ICSession.webSession #-ErrorAction Stop
  [PSCustomObject] $response
} # }}}2

