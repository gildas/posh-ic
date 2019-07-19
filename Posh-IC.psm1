if (Get-Module Posh-IC) { return }

if ($PSVersionTable.PSVersion.Major -lt 3)
{
  Write-Error "Posh-IC work only on Powershell 3.0 and higher"
  exit
}

Push-Location $PSScriptRoot
. .\__Add-Types.ps1
Update-FormatData -AppendPath .\__display.formats.ps1xml
. .\New-ICSession.ps1
. .\Remove-ICSession.ps1
. .\Get-ICSessionStatus.ps1
. .\Get-ICUserStatus.ps1
. .\Get-ICUser.ps1
. .\Get-ICUsers.ps1
. .\New-ICUser.ps1
. .\New-ICUsers.ps1
. .\Remove-ICUser.ps1
. .\Get-ICWorkgroup.ps1
. .\Get-ICWorkgroups.ps1
. .\New-ICWorkgroup.ps1
. .\New-ICWorkgroups.ps1
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
. .\Import-AttProfile.ps1
. .\Export-AttProfile.ps1
. .\Set-ICLicense.ps1
. .\Get-ICUserByNtUserId.ps1
. .\Get-ICRoles.ps1
Pop-Location

Export-ModuleMember `
  -Function @(
    'New-ICSession',
    'Remove-ICSession',
    'Get-ICSessionStatus',
    'Get-ICUserStatus',
    'Get-ICUser',
    'Get-ICUserByNtUserId',
    'Get-ICRoles',
    'Get-ICUsers',
    'New-ICUser',
    'New-ICUsers',
    'Remove-ICUser',
    'Get-ICWorkgroup',
    'Get-ICWorkgroups',
    'New-ICWorkgroup',
    'New-ICWorkgroups',
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
    'Get-ICLicenseAllocations',
    'Import-AttProfile',
    'Export-AttProfile',
    'Set-ICLicense',
    'Get-ICUserByNtUserId',
    'Get-ICRoles'
  )
