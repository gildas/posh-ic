<#
# AUTHOR : Pierrick Lozach
#>

function Get-ICLicenseAllocations() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets a list of all additional licenses
.DESCRIPTION
  Gets a list of all additional licenses, as shown in the User "Licensing" tab
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

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/license-allocations" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Output $response | Format-Table
  [PSCustomObject] $response
} # }}}2

