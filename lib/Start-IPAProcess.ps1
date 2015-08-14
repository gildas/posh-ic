<#
# AUTHOR : Pierrick Lozach
#>

function Start-IPAProcess() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Launches an IPA process
.DESCRIPTION
  Launches an IPA process.
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER DefinitionId
  The process definition id of the process that is to be launched
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("ProcessId")] [string] $DefinitionId
  )

  #TODO Check if process exist before trying to run it. Get-IPAProcess returns 403 at the moment.
  
  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $body = ConvertTo-Json(@{
   "processDefinitionId" = $DefinitionId
  })

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/ipa/process-instances" -Body $body -Method Post -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Verbose "Response: $response"
  [PSCustomObject] $response
} # }}}2

