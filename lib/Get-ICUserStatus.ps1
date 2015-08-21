<#
# AUTHOR : Gildas Cherruel
#>

function Get-ICUserStatus() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets the status of the given user
.DESCRIPTION
  Gets the status of the given user. If no user is given, the connected user will be used
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUser
  The Interaction Center User
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]
    [Alias("Session", "Id")]
    [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$false)]
    [Alias("User")]
    [ININ.ICUser] $ICUser
  )

  if (! $PSBoundParameters.ContainsKey('ICUser'))
  {
    $ICUser = $ICSession.user
  }
  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/status/user-statuses/$($ICUser.id)" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Output $response | Format-Table
  [PSCustomObject] $response
} # }}}2

