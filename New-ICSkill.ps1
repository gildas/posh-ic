<#
# AUTHOR : Pierrick Lozach
#>

function New-ICSkill() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Creates a new IC skill
.DESCRIPTION
  Creates a new IC skill
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICSkill
  The Interaction Center Skill
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("Skill")] [string] $ICSkill
  )

  $skillExists = Get-ICSkill $ICSession -ICSkill $ICSkill
  if (-not ([string]::IsNullOrEmpty($skillExists))) {
    return
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $body = ConvertTo-Json(@{
   "configurationId" = New-ICConfigurationId $ICSkill
  })

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/skills" -Body $body -Method Post -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Output $response | Format-Table
  [PSCustomObject] $response
} # }}}2

