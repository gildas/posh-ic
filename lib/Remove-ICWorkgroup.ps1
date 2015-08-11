<#
# AUTHOR : Pierrick Lozach
#>

function Remove-ICWorkgroup() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Removes a workgroup
.DESCRIPTION
  Removes a workgroup
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

  # Workgroup exists?
  $workgroupExists = Get-ICWorkgroup $ICSession -ICWorkgroupId $ICWorkgroupId
  if ([string]::IsNullOrEmpty($workgroupExists)) {
    # Workgroup does not exist
    return
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/workgroups/$ICWorkgroupId" -Method Delete -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop

  Write-Verbose "Response: $response"
  [PSCustomObject] $response
} # }}}2

