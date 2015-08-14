<#
# AUTHOR : Pierrick Lozach
#>

function Export-IPAProcess() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Exports an IPA process
.DESCRIPTION
  Exports an IPA process from a currently running CIC server
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER Password
  The password to the logged in user
.PARAMETER Path
  The path to the folder to save the exported process to. Do not specify a filename.
.PARAMETER ExportType
  Either "Process" or "ProcessTemplate" depending on the type of process to export. If ommitted, "Process" will be used
.PARAMETER ExportVersion
  The version of the process to export. "CheckedIn", "Published", "Latest" or <Specific Version>. If ommitted, "Latest" will be used.
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [string] $Password,
    [Parameter(Mandatory=$true)] [string] $Path,
    [Parameter(Mandatory=$false)] [string] $ExportType,
    [Parameter(Mandatory=$false)] [string] $ExportVersion
  )

  # Get path to i3\ic\server directory
  $cicPath = (Get-ItemProperty -LiteralPath "HKLM:\SOFTWARE\Wow6432Node\Interactive Intelligence").Target

  # Set arguments
  $filename = "$($cicPath)FlowUtil.exe"
  $arguments = "/user=$($ICSession.user.id) /password=$($Password) /server=$($ICSession.server) /export /exportToPath='$($Path)'"
  
  # Add exportType flag
  if ([string]::IsNullOrEmpty($ExportType)) {
    $arguments += " /exportType=Process"
  } else {
    $arguments += " /exportType=$($ExportType)"
  }

  # Add exportVersion flag
  if ([string]::IsNullOrEmpty($ExportVersion)) {
    $arguments += " /exportVersion=Latest"
  } else {
    $arguments += " /exportVersion=$($ExportVersion)"
  }
  
  # Create process object
  $process = New-Object System.Diagnostics.Process
  $process.StartInfo.FileName = $filename
  $process.StartInfo.Arguments = $arguments
  $process.StartInfo.UseShellExecute = $false
  $process.StartInfo.RedirectStandardOutput = $true
  $process.StartInfo.RedirectStandardError = $true
 
  Write-Output $process.StartInfo.Arguments

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