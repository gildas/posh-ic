<#
# AUTHOR : Pierrick Lozach
#>

function Get-ICWorkgroup() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets a workgroup
.DESCRIPTION
  Gets a workgroup
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICWorkgroup
  The Interaction Center Workgroup
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("WorkgroupId")] [string] $ICWorkgroupId
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = '';

  try {
      $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/workgroups/$ICWorkgroupId" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
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

