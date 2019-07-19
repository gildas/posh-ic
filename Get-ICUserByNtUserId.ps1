<#
# AUTHOR : Paul McGurn, based on Pierrick Lozach's original work
#>

function Get-ICUserByNtUserId() 
{
# Documentation 
<#
.SYNOPSIS
  Gets an IC User by lookup of their NT user ID
.DESCRIPTION
  Gets an IC User by lookup of their NT user ID
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER NtUserId
  The NT User ID for the user, ex. MyDomain\jsmith
#> 
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)]  [Alias("NtUserId", "User")] [String] $ICNtUserId

  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $uri = $ICsession.baseURL + '/' + $ICSession.id + '/configuration/users?where='
  $whereclause = 'ntDomainUser eq ' + [System.Web.HttpUtility]::UrlEncode($ICNtUserId)
  $encodeduri = $uri + $whereclause

  $response = Invoke-RestMethod -Uri $encodeduri -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop

  return [PSCustomObject]$response.items.configurationid

} 

