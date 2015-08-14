<#
# AUTHOR : Pierrick Lozach
#>

function New-ICWorkgroup() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Creates a new CIC workgroup
.DESCRIPTION
  Creates a new CIC workgroup
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICWorkgroup
  The Interaction Center Workgroup Identifier
.PARAMETER Extension
  The Interaction Center Workgroup Extension
.PARAMETER Members
  The Interaction Center Workgroup Members
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("Workgroup")] [string] $ICWorkgroup,
    [Parameter(Mandatory=$false)] [string] $Extension,
    [Parameter(Mandatory=$false)] [string[]] $Members,
    [Parameter(Mandatory=$false)] [boolean] $HasQueue,
    [Parameter(Mandatory=$false)] [string] $QueueType,
    [Parameter(Mandatory=$false)] [boolean] $IsActive
  )

  $workgroupExists = Get-ICWorkgroup $ICSession -ICWorkgroup $ICWorkgroup
  if (-not ([string]::IsNullOrEmpty($workgroupExists))) {
    return
  }

  # Parameter validation
  if (!$PSBoundParameters.ContainsKey('IsActive'))
  {
    $IsActive = $True
  }

  if (!$PSBoundParameters.ContainsKey('HasQueue'))
  {
    $HasQueue = $True
  }

  # Queue Type
  $QueueTypeInt = 5 # Default is ACD
  switch($QueueType.ToLower())
  {
    "none"       { $QueueTypeInt = 0 }
    "custom"     { $QueueTypeInt = 1 }
    "groupring"  { $QueueTypeInt = 2 }
    "sequential" { $QueueTypeInt = 3 }
    "roundrobin" { $QueueTypeInt = 4 }
    "acd"        { $QueueTypeInt = 5 } # No need to add this but oh well...
  }

  if (!$PSBoundParameters.ContainsKey('QueueType'))
  {
    $QueueType = "ACD"
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $body = ConvertTo-Json(@{
   "configurationId" = New-IcConfigurationId $ICWorkgroup
   "extension"       = $Extension
   "hasQueue"        = $HasQueue
   "queueType"       = 5
   "isActive"        = $IsActive
   "members"         = @( $Members | foreach { New-ICConfigurationId $_ } )
  })

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/workgroups" -Body $body -Method Post -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Verbose "Response: $response"
  [PSCustomObject] $response
} # }}}2