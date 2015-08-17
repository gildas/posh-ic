<#
# AUTHOR : Pierrick Lozach
#>

function Remove-ICSkill() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Removes a skill
.DESCRIPTION
  Removes a skill
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

  # Skill exists?
  $skillExists = Get-ICSkill $ICSession -ICSkill $ICSkill
  if ([string]::IsNullOrEmpty($skillExists)) {
    # Skill does not exist
    return
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/skills/$ICSkill" -Method Delete -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  [PSCustomObject] $response
} # }}}2

