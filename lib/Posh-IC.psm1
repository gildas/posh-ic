if (Get-Module Posh-IC) { return }

if ($PSVersionTable.PSVersion.Major -lt 3)
{
  Write-Error "Posh-IC work only on Powershell 3.0 and higher"
  exit
}

Push-Location $PSScriptRoot
. .\__Add-Types.ps1
. .\New-ICSession.ps1
. .\Remove-ICSession.ps1
. .\Get-ICSessionStatus.ps1
. .\Get-ICUserStatus.ps1
. .\Get-ICUsers.ps1
. .\New-ICUser.ps1
. .\Get-ICUser.ps1
. .\Remove-ICUser.ps1
. .\Get-ICWorkgroups.ps1
. .\Get-ICWorkgroup.ps1
. .\New-ICWorkgroup.ps1
. .\Remove-ICWorkgroup.ps1
. .\New-ICConfigurationId.ps1
. .\Get-IPAProcesses.ps1
. .\Get-IPAProcess.ps1
. .\Start-IPAProcess.ps1
. .\Import-IPAProcess.ps1
. .\Export-IPAProcess.ps1
. .\Get-ICSkills.ps1
. .\Get-ICSkill.ps1
. .\New-ICSkill.ps1
. .\Remove-ICSkill.ps1
. .\Get-ICLicenseAllocations.ps1
Pop-Location

Export-ModuleMember `
  -Function @(
    'New-ICSession',
    'Remove-ICSession',
    'Get-ICSessionStatus',
    'Get-ICUserStatus',
    'Get-ICUsers',
    'New-ICUser',
    'Get-ICUser',
    'Remove-ICUser',
    'Get-ICWorkgroups',
    'Get-ICWorkgroup',
    'New-ICWorkgroup',
    'Remove-ICWorkgroup',
    'New-ICConfigurationId',
    'Get-IPAProcesses',
    'Get-IPAProcess',
    'Start-IPAProcess',
    'Import-IPAProcess',
    'Export-IPAProcess',
    'Get-ICSkills',
    'Get-ICSkill',
    'New-ICSkill',
    'Remove-ICSkill',
    'Get-ICLicenseAllocations'
  )
