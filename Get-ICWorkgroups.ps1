<#
# AUTHOR : Pierrick Lozach
#>

function Get-ICWorkgroups() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets a list of all workgroups
.DESCRIPTION
  Gets a list of all workgroups
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
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/workgroups" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Output $response | Format-Table
  [PSCustomObject] $response
} # }}}2

