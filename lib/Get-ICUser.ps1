<#
# AUTHOR : Pierrick Lozach
#>

function Get-ICUser() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets a user
.DESCRIPTION
  Gets a user
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUser
  The Interaction Center User
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("UserId")] [string] $ICUserId
  )

  if (! $PSBoundParameters.ContainsKey('ICUserId'))
  {
    $ICUserId = $ICSession.user
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = '';

  try {
      $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users/$ICUserId" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  }
  catch [System.Net.WebException] {
    # If user not found, ignore the exception
    if (-not ($_.Exception.message -match '404')) {
        Write-Error $_
    }
  }

  Write-Verbose "Response: $response"
  [PSCustomObject] $response
} # }}}2

