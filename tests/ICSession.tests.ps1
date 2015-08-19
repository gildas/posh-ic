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

Describe "New-ICSession" { # {{{
  Context "When using wrong server" { # {{{
    It "should throw an error" { # {{{
      $server   = "nowhere-12875623.localdomain"
      $user     = 'nobody'
      $password = 'nothing'

      { New-ICSession -ComputerName $server -User $user -Password $password } | Should Throw
      $error[0].FullyQualifiedErrorId | Should Match 'System\.Net\.WebException.*'
      $error[0].Exception | Should Match 'The remote name could not be resolved:.*'
    } # }}}
  } # }}}

  Context "When using wrong credential" { # {{{
    BeforeEach { $config   = $configs.simple }
    It "should throw an error" { # {{{
      $server   = $config.server
      $user     = $config.user
      $password = 'nothing'

      { New-ICSession -ComputerName $server -User $user -Password $password } | Should Throw
      $error[0].Exception.GetType() | Should Be 'System.Net.WebException'
      $error[0].ErrorDetails | Should Not BeNullOrEmpty
      { $error[0].ErrorDetails | ConvertFrom-Json } | Should Not Throw
      ($error[0].ErrorDetails | ConvertFrom-Json).errorId   | Should Be 'error.request.connection.authenticationFailure'
      ($error[0].ErrorDetails | ConvertFrom-Json).errorCode | Should Be '-2147221503'
    } # }}}
  } # }}}

  Context "When using wrong session identifier" { # {{{
    BeforeEach { $config   = $configs.simple }
    It "should throw" { # {{{
      $server   = $config.server
      $user     = $config.user
      $password = $config.password

      $session = New-ICSession -ComputerName $server -User $user -Password $password
      $session    | Should Not BeNullOrEmpty
      $session.id | Should Not BeNullOrEmpty
      $wrong    = $session
      $wrong.id = '10012345678'
      { Remove-ICSession -ICSession $wrong } | Should Throw
      $error[0].FullyQualifiedErrorId | Should Match 'WebCmdletWebResponseException.*'
      { $error[0].ErrorDetails | ConvertFrom-Json } | Should Not Throw
      ($error[0].ErrorDetails | ConvertFrom-Json).errorCode | Should Be '1'
      ($error[0].ErrorDetails | ConvertFrom-Json).message   | Should Be 'This request requires a session ID!'
    } # }}}
  } # }}}

  Context "When using wrong token" { # {{{
    BeforeEach { $config   = $configs.simple }
    It "should throw" { # {{{
      $server   = $config.server
      $user     = $config.user
      $password = $config.password

      $session = New-ICSession -ComputerName $server -User $user -Password $password
      $session    | Should Not BeNullOrEmpty
      $session.id | Should Not BeNullOrEmpty
      $wrong = $session
      $wrong.token = 'ABC7uiitfghnWR0NG'
      { Remove-ICSession -ICSession $wrong } | Should Throw
      $error[0].FullyQualifiedErrorId | Should Match 'WebCmdletWebResponseException.*'
      { $error[0].ErrorDetails | ConvertFrom-Json } | Should Not Throw
      ($error[0].ErrorDetails | ConvertFrom-Json).errorCode | Should Be '2'
      ($error[0].ErrorDetails | ConvertFrom-Json).message   | Should Be 'An authentication token was expected in the request, but not found.'
    } # }}}
  } # }}}

  Context "When existing server and good credential are used" { # {{{
    BeforeEach { $config   = $configs.simple }
    It "should log in" { # {{{
      $server   = $config.server
      $user     = $config.user
      $password = $config.password

      $session = New-ICSession -ComputerName $server -User $user -Password $password
      $session    | Should Not BeNullOrEmpty
      $session.id | Should Not BeNullOrEmpty
    } # }}}

    It "should log out" { # {{{
      $server   = $config.server
      $user     = $config.user
      $password = $config.password

      $session = New-ICSession -ComputerName $server -User $user -Password $password
      $session    | Should Not BeNullOrEmpty
      $session.id | Should Not BeNullOrEmpty
      Remove-ICSession $session
      $state = Get-ICSessionStatus $session
      $state | Should Be Down
    } # }}}
  } # }}}

  Context "When using Out of Server Session Manager (OSSM)" { # {{{
    BeforeEach { $config   = $configs.ossm }
    It "should log in" { # {{{
      $server   = $config.server
      $user     = $config.user
      $password = $config.password

      $session = New-ICSession -ComputerName $server -User $user -Password $password
      $session    | Should Not BeNullOrEmpty
      $session.id | Should Not BeNullOrEmpty
    } # }}}
  } # }}}

  BeforeEach { # {{{
    $configs = (Get-Content -Raw -Path '.\config.json' | ConvertFrom-Json)
    $session = $null
  } # }}}

  AfterEach { # {{{
    if ($session -ne $null)
    {
      Remove-ICSession -ICSession $session
    }
  } # }}}
} # }}}
