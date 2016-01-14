<#
# AUTHOR : Gildas Cherruel
#>

function Remove-ICSession() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Disconnects from an Interaction Center server
.DESCRIPTION
  Disconnects from an Interaction Center server
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
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/connection" -Method Delete -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
} # }}}2
