<#
# AUTHOR : Gildas Cherruel
#>

function Get-ICSessionStatus() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Gets the status of an ICSession
.DESCRIPTION
  Gets the status of an ICSession
.PARAMETER ICSession
  The Interaction Center Session
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]
    [Alias("Session", "Id")]
    [ININ.ICSession] $ICSession
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }
  try
  {
    $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/connection" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
    Write-Verbose "Response: $response"

    [ININ.ConnectionState] $response.connectionState
  }
  catch [System.Net.WebException]
  {
    if ($_.Exception.Response.StatusCode -eq 'Unauthorized')
    {
      $details = $_.ErrorDetails | ConvertFrom-Json
      if ( `
          (($details.errorId -eq 'error.request.connection.authenticationFailure') -and `
           ($details.errorCode -eq -2147221499)) ` <# Session Identifier is invalid #> `
          -or `
          ($details.errorCode -eq 1)               <# Session Identifier is wrong format #> `
          -or `
          ($details.errorCode -eq 2)               <# Session Identifier was not found #> `
        )
      {
        return [ININ.ConnectionState]::Down
      }
    }
    Throw $_
  }
} # }}}2
