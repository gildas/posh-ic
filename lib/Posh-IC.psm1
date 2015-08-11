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
    'New-ICConfigurationId'
  )
