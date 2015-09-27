<#
# AUTHOR : Pierrick Lozach
#>

function Set-ICLicense() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Assigns a CIC license to a user
.DESCRIPTION
  Assigns a CIC license to a specific CIC user.
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUser
  The Interaction Center User Identifier
.PARAMETER HasClientAccess
  If true, user is allowed to access the Interaction Client or Desktop applications. Default value is true.
.PARAMETER LicenseActive
  If true, assigned licenses should be considered active by the server. Default value is true.
.PARAMETER MediaLevel
  Used to configure how many interaction types an ACD user can handle at a specified time. Set to 0 for None, 1, 2 or 3. Default value is 3.
.PARAMETER AdditionalLicenses
  List of additional licenses to assign to the user.
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("User")] [string] $ICUser,
    [Parameter(Mandatory=$false)] [Alias("ClientAccess")] [boolean] $HasClientAccess,
    [Parameter(Mandatory=$false)] [Alias("EnableLicenses", "ActivateLicenses")] [boolean] $LicenseActive,
    [Parameter(Mandatory=$false)] [Alias("MediaLicense")] [int] $MediaLevel,
    [Parameter(Mandatory=$false)] [string[]] $AdditionalLicenses
  )

  $userExists = Get-ICUser $ICSession -ICUser $ICUser
  if ([string]::IsNullOrEmpty($userExists)) {
    return
  }

  if (!$PSBoundParameters.ContainsKey('HasClientAccess'))
  {
    $HasClientAccess = $true
  }

  if (!$PSBoundParameters.ContainsKey('LicenseActive'))
  {
    $LicenseActive = $true
  }

  if (!$PSBoundParameters.ContainsKey('MediaLevel'))
  {
    $MediaLevel = 3
  }

  # Add headers
  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  # Build base body
  $body = @{
   "configurationId" = New-ICConfigurationId $ICUser
   "extension" = $Extension
  }

  ############
  # Licenses #
  ############
  $licenseProperties = @{
    "hasClientAccess" = $HasClientAccess
    "licenseActive" = $LicenseActive
    "mediaLevel" = $MediaLevel
  }

  # Add Additional Licenses if there are any
  if ($AdditionalLicenses) {
    # Add all licenses?
    if ($AdditionalLicenses.Length -eq 1 -and $AdditionalLicenses[0] -eq "*") {
      $allAdditionalLicenses = ((Get-ICLicenseAllocations $cic).items | foreach { if (-not ($_.configurationId.id -match "EASYSCRIPTER" -or $_.configurationId.id -match "MSCRM")) { $_.configurationId } })
      # Add missing licenses
      $allAdditionalLicenses += New-ICConfigurationId "I3_ACCESS_IPAD_USER_SUPERVISOR"
      $allAdditionalLicenses += New-ICConfigurationId "I3_OPTIMIZER_SHOWRTA"
      $allAdditionalLicenses += New-ICConfigurationId "I3_OPTIMIZER_SCHEDULABLE"

      $licenseProperties.Add("additionalLicenses", $allAdditionalLicenses)
    }
    else {
      $licenseProperties += @{
        "additionalLicenses" = @( $AdditionalLicenses | foreach { New-ICConfigurationId $_ } )
      }
    }
  }

  if (![string]::IsNullOrEmpty($licenseProperties)) {
    $body += @{
     "licenseProperties" = $licenseProperties
    }
  }

  $body = ConvertTo-Json($body) -Depth 4

  # Call it!
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users/$($ICUser)" -Body $body -Method Put -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Output $response | Format-Table
  [PSCustomObject] $response
} # }}}2
