#
# Pester tests for: ICSession
#
# See https://github.com/pester/Pester
#

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$lib  = Join-Path (Split-Path -Parent $here) 'lib'

Push-Location $lib
  Import-Module .\Posh-IC.psm1
Pop-Location

Describe "Get-ICSessionStatus" { # {{{
  It "Should have a proper session" { # {{{
    $session    | Should Not BeNullOrEmpty
    $session.id | Should Not BeNullOrEmpty
  } # }}}
  
  Context "When connected" { # {{{
    It "ConnectionState object should have the proper class" { # {{{
      $state = Get-ICSessionStatus $session
      $state.GetType().Name | Should Be 'ConnectionState'
    } # }}}

    It "ConnectionState should be Up" { # {{{
      $state = Get-ICSessionStatus $session
      $state | Should Be Up
    } # }}}
  } # }}}

  Context "When disconnected" { # {{{
    It "should be Down" { # {{{
      Write-Verbose "disconnecting $($session.id) from $($session.server)"
      Remove-ICSession $session 
      Write-Verbose "Session: $($session.id) disconnected from $($session.server)"
      $state = Get-ICSessionStatus $session
      $state | Should Be Down
    } # }}}
  } # }}}

  Context "When invalid session" { # {{{
    It "should be Down" { # {{{
      $fake = $session
      $fake.id = '10123456'
      $state = Get-ICSessionStatus $fake
      $state | Should Be Down
    } # }}}
  } # }}}

  BeforeEach { # {{{
    $config = (Get-Content -Raw -Path '.\config.json' | ConvertFrom-Json)
    $session = New-ICSession -ComputerName $config.server -User $config.user -Password $config.password
    Write-Verbose "Session: $($session.id) connected to $($session.server) as $($session.user.id)"
  } # }}}

  AfterEach { # {{{
    if ($session -ne $null)
    {
      try { Remove-ICSession -ICSession $session } catch { }
      Write-Verbose "Session: $($session.id) disconnected from $($session.server)"
    }
  } # }}}
} # }}}
