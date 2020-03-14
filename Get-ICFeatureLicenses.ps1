<#
# AUTHOR : Paul McGurn
#>

function Get-ICFeatureLicenses() {
    # {{{2
    # Documentation {{{3
    <#
.SYNOPSIS
  Gets a list of all feature licenses
.DESCRIPTION
  Gets a list of all feature licenses, as shown in the User "Licensing" tab
.PARAMETER ICSession
  The Interaction Center Session
#> # }}}3
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]  [Alias("Session", "Id")] $ICSession
    )

    $headers = @{
        "Accept-Language"      = $ICSession.language;
        "ININ-ICWS-CSRF-Token" = $ICSession.token;
    }

    $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/feature-licenses?select=*" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
    Write-Output $response | Format-Table
    [PSCustomObject] $response
} # }}}2

