<#
# AUTHOR : Pierrick Lozach
#>

function Export-AttProfile() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Exports an Interaction Attendant profile
.DESCRIPTION
  Exports All or specific Interaction Attendant profiles
.PARAMETER ProfileName
  The Interaction Attendant profile to export. If not specified, all profiles will be exported.

#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$false)] [Alias("Profile")] [string] $ProfileName
  )

  # Get Attendant Root registry key
  $serverPath = (Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence\EIC\Directory Services\Root').SERVER
  $attendantRoot = "HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence\EIC\Directory Services\Root$serverPath\AttendantData"
  $activeAttendant = (Get-ItemProperty $attendantRoot).ActiveConfig
  $activeAttendantRoot = "$attendantRoot\$activeAttendant"

  $filename = ''

  if (-not [string]::IsNullOrEmpty($ProfileName)) {
    # Export specific profile
    $attendantProfiles = .\Search-Registry.ps1 -StartKey $activeAttendantRoot -Pattern $ProfileName -MatchData -ExactMatch
    $attendantProfiles | ForEach-Object {
      $filename = $_.Data + ".reg"
      Reg Export $_.Key $filename /y
    }
  }
  else {
    # Export all profiles
    $filename = $env:computername + ".reg"
    Reg Export $activeAttendantRoot.Replace(':','') $filename /y
  }

  # Get local SITE & server name
  $site = (Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence\EIC\Directory Services\Root').SITE.Replace('\','')
  $serverPath -match "\w+$" # Get end of string
  $server = $matches[0]

  # Replace Site and Server values with keywords (<SITE> AND <SERVER>) that will be used by Import-AttProfile
  $regfilecontents = (Get-Content $filename).Replace($site, '<SITE>').Replace($server, '<SERVER>') | Out-File $filename -Force

  Write-Output "Profile(s) exported to $filename"
} # }}}2