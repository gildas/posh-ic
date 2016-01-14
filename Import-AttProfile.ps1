<#
# AUTHOR : Pierrick Lozach
#>

function Import-AttProfile() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Imports Interaction Attendant profiles
.DESCRIPTION
  Imports .reg files containing Interaction Attendant profiles into the active Attendant configuration on a CIC server. Replaces the site and server name based on the CIC configuration.
.PARAMETER RegistryFile
  The registry file to import. If not specified, all .reg files in the current directory will be imported.

#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$false)] [Alias("Registry")] [string] $RegistryFile
  )

  # Get Attendant Root registry key
  $serverPath = (Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence\EIC\Directory Services\Root').SERVER
  $attendantRoot = "HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence\EIC\Directory Services\Root$serverPath\AttendantData"
  $activeAttendant = (Get-ItemProperty $attendantRoot).ActiveConfig
  $activeAttendantRoot = "$attendantRoot\$activeAttendant"

  $regfiles = @()

  # List all .reg files or use the one specified in the $RegistryProfile parameter
  if ([string]::IsNullOrEmpty($RegistryFile)) {
    $regfiles = Get-ChildItem -Recurse | Where {$_.Extension -eq ".reg" } | Select-Object FullName
  } else {
    $regfiles = Get-ChildItem $RegistryFile -Recurse | Select-Object FullName
  }

  # Get local SITE and Server name
  $site = (Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence\EIC\Directory Services\Root').SITE.Replace('\','')
  $serverPath -match "\w+$" # Get end of stImportring
  $server = $matches[0]

  # Import Process
  $regfiles | ForEach-Object {
    $regfilename = $_.FullName
    $outregfilename = $regfilename + '.import'
    # Load the .reg file, replace keywords that were inserted by Export-AttProfile and save output to temp file
    (Get-Content $regfilename).Replace('<SITE>', $site).Replace('<SERVER>', $server) | Out-File $outregfilename -Force
    # Import the reg file
    Start-Process -FilePath reg -ArgumentList "Import $outregfilename" -Wait -RedirectStandardError $true # Using "Reg Import $outregfilename" outputs "the operation completed successfully" to stderr!
    # Delete the temp file
    Remove-Item $outregfilename
  }

} # }}}2