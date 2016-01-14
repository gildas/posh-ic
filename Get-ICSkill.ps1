<#
# AUTHOR : Pierrick Lozach
#>

function Get-ICSkill() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets a skill
.DESCRIPTION
  Gets a skill
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICSkill
  The Interaction Center Skill
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("Skill")] [string] $ICSkill
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = '';

  try {
      $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/skills/$ICSkill" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  }
  catch [System.Net.WebException] {
    # If skill not found, ignore the exception
    if (-not ($_.Exception.message -match '404')) {
        Write-Error $_
    }
  }
  [PSCustomObject] $response
} # }}}2

