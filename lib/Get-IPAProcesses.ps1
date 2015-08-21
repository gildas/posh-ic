<#
# AUTHOR : Pierrick Lozach
#>

function Get-IPAProcesses() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets a list of all IPA processes
.DESCRIPTION
  Gets a list of all IPA processes
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

  # Get date using ISO 8601 format
  $currentdate = Get-Date -Format s
  $aYearAgo = (Get-Date).AddYears(-1).ToString("s")

  $query = "/?beginSearchWindow=$($aYearAgo)&endSearchWindow=$($currentDate)"
  
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/ipa/process-instances$($query)" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Output $response | Format-Table
  [PSCustomObject] $response
} # }}}2

