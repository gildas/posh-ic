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
Pop-Location

Export-ModuleMember `
  -Function @(
    'New-ICSession',
    'Remove-ICSession',
    'Get-ICSessionStatus',
    'Get-ICUserStatus'
  )
