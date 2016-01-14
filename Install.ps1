[CmdletBinding()]
Param(
  [Parameter(Position=1, Mandatory=$false)]
  $Path
)

$ModuleName    = 'Posh-IC'
$ModuleVersion = '0.0.5'
$GithubRoot    = "https://raw.githubusercontent.com/gildas/posh-ic/$ModuleVersion"

if ([string]::IsNullOrEmpty($Path))
{
  $my_modules   = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Modules'
  $module_paths = @($env:PSModulePath -split ';')

  if (! (Test-Path $my_modules))
  {
    Write-Verbose "Creating Personal Powershell Module folder"
    New-Item -ItemType Directory -Path $my_modules -ErrorAction Stop | Out-Null
  }

  if ($module_paths -notcontains $my_modules)
  {
    Write-Verbose "Adding Personal Powershell Module folder to Module Search list"
    $env:PSModulePath = $my_modules + ';' + $env:PSModulePath
    [Environment]::SetEnvironmentVariable('PSModulePath', $env:PSModulePath, 'User')
  }
  $Path = Join-Path $my_modules $ModuleName
}

if (! (Test-Path $Path))
{
  Write-Verbose "Creating $ModuleName Module folder"
  New-Item -ItemType Directory -Path $Path -ErrorAction Stop | Out-Null
}

@(
  'LICENSE',
  'VERSION',
  'README.md',
  'Posh-IC.psd1',
  'Posh-IC.psm1'
  '__Add-Types.ps1'
  '__display.formats.ps1xml',
  'New-ICSession.ps1',
  'Remove-ICSession.ps1',
  'Get-ICSessionStatus.ps1',
  'Get-ICUserStatus.ps1',
  'Get-ICUser.ps1',
  'Get-ICUsers.ps1',
  'New-ICUser.ps1',
  'New-ICUsers.ps1',
  'Remove-ICUser.ps1',
  'Get-ICWorkgroup.ps1',
  'Get-ICWorkgroups.ps1',
  'New-ICWorkgroup.ps1',
  'New-ICWorkgroups.ps1',
  'Remove-ICWorkgroup.ps1',
  'New-ICConfigurationId.ps1',
  'Get-IPAProcesses.ps1',
  'Get-IPAProcess.ps1',
  'Start-IPAProcess.ps1',
  'Import-IPAProcess.ps1',
  'Export-IPAProcess.ps1',
  'Get-ICSkills.ps1',
  'Get-ICSkill.ps1',
  'New-ICSkill.ps1',
  'Remove-ICSkill.ps1',
  'Get-ICLicenseAllocations.ps1',
  'Import-AttProfile.ps1',
  'Export-AttProfile.ps1',
  'Set-ICLicense.ps1'
) | ForEach-Object {
  Start-BitsTransfer -DisplayName "$ModuleName Installation" -Description "Installing $_" -Source "$GithubRoot/$_" -Destination $Path -ErrorAction Stop
}
