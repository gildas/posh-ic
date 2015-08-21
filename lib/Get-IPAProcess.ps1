<#
# AUTHOR : Pierrick Lozach
#>

function Get-IPAProcess() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets an IPA process
.DESCRIPTION
  Gets an IPA process
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER DefinitionId
  The process definition id of the process
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("ProcessId")] [string] $DefinitionId
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  # Get date using ISO 8601 format
  $currentdate = Get-Date -Format s
  $aYearAgo = (Get-Date).AddYears(-1).ToString("s")

  $query = "/?beginSearchWindow=$($aYearAgo)&endSearchWindow=$($currentDate)&where definitionId eq $($DefinitionId)"
  
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/ipa/process-instances/$($query)" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  [PSCustomObject] $response
} # }}}2

