<#
# AUTHOR : Pierrick Lozach
#>

function New-ICUser() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Creates a new IC user
.DESCRIPTION
  Creates a new IC user. If password is ommitted, default value is '1234'
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER UserId
  The Interaction Center User Identifier
.PARAMETER Password
  The Interaction Center User Password
.PARAMETER Extension
  The Interaction Center User Extension
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [string] $UserId,
    [Parameter(Mandatory=$false)] [string] $Password,
    [Parameter(Mandatory=$false)] [string] $Extension
  )

  $userExists = Get-ICUser $ICSession -ICUserId $UserId
  if (-not ([string]::IsNullOrEmpty($userExists))) {
    return
  }

  if (!$PSBoundParameters.ContainsKey('Password'))
  {
    $Password = '1234'
  }


  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $body = ConvertTo-Json(@{
   "configurationId" = New-ICConfigurationId $UserId
   "extension" = $Extension
  })

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users" -Body $body -Method Post -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Verbose "Response: $response"
  [PSCustomObject] $response
} # }}}2

