<#
# AUTHOR : Gildas Cherruel
#>

function Get-ICSessionStatus() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets the status of an ICSession
.DESCRIPTION
  Gets the status of an ICSession
.PARAMETER ICSession
  The Interaction Center Session
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]
    [Alias("Session", "Id")]
    [ININ.ICSession] $ICSession
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/connection" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Verbose "Response: $response"

  [ININ.ConnectionState] $response.connectionState
} # }}}2
