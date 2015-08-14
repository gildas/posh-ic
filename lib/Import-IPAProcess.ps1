<#
# AUTHOR : Pierrick Lozach
#>

function Import-IPAProcess() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Imports an IPA process
.DESCRIPTION
  Imports an IPA process that is stored in a file
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER Password
  The password to the logged in user
.PARAMETER Path
  The path to the IPA process to import
.PARAMETER Publish
  Set to yes to publish the imported process. Default value is yes.
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [string] $Password,
    [Parameter(Mandatory=$true)] [string] $Path,
    [Parameter(Mandatory=$false)] [boolean] $Publish
  )

  # Get path to i3\ic\server directory
  $cicPath = (Get-ItemProperty -LiteralPath "HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence").Target

  # Set arguments
  $filename = "$($cicPath)FlowUtil.exe"
  $arguments = "/user=$($ICSession.user.id) /password=$($Password) /server=$($ICSession.server) /import=`"$($Path)`""
  
  # Add publish flag
  if ([string]::IsNullOrEmpty($Publish) -or $Publish) {
    $arguments += " /publish"
  }
  
  # Create process object
  $process = New-Object System.Diagnostics.Process
  $process.StartInfo.FileName = $filename
  $process.StartInfo.Arguments = $arguments
  $process.StartInfo.UseShellExecute = $false
  $process.StartInfo.RedirectStandardOutput = $true
  $process.StartInfo.RedirectStandardError = $true
 
  # Start the process & Format output
  if ($process.Start()) {
    $error = $process.StandardError.ReadToEnd()
    if ($error) {
      Write-Error $error
      return
    }

    $output = $process.StandardOutput.ReadToEnd() -replace "\r\n$", ""
    if ($output) {
      if ($output.Contains("`r`n")) {
        $output -split "`r`n"
      }
      elseif ($output.Contains("`n")) {
        $output -split "`n"
      }
      else {
        $output
      }
    }
  }

  # Wait until the process ends and get Exit Code
  $process.WaitForExit() 
  & "$Env:SystemRoot\system32\cmd.exe" /c exit $process.ExitCode
  
  $response = @{
    "Output" = $output
    "ExitCode" = $process.ExitCode
  }

  Write-Verbose "Response: $response"
  [PSCustomObject] $response
} # }}}2