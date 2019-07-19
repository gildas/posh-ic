<#
# AUTHOR : Pierrick Lozach
#>

function Get-ICRoles() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets a list of IC Roles
.DESCRIPTION
  Gets a list of IC Roles
.PARAMETER ICSession
  The Interaction Center Session
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = '';

  try {
      $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/roles" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  }
  catch [System.Net.WebException] {
    # If user not found, ignore the exception
    if (-not ($_.Exception.message -match '404')) {
        Write-Error $_
    }
  }
  [PSCustomObject] $response
} # }}}2

