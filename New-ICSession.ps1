<#
# AUTHOR : Gildas Cherruel
#>

function New-ICSession() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Connects to an Interaction Centerò server
.DESCRIPTION
  Connects to an Interaction Centerò server
.PARAMETER ComputerName
  The Interaction Center to connect to.
.PARAMETER User
  The User to connect with
.PARAMETER Password
  The passwprd for the User
#> # }}}3
  [CmdletBinding(DefaultParameterSetName='Credential')]
  [OutputType([ININ.ICSession])]
  Param(
    [Parameter(Position=1, Mandatory=$true)]
    [Alias("ICServer", "Server", "Notifier")]
    [string] $ComputerName,
    [Parameter(Position=2, ParameterSetName='Credential', Mandatory=$true)]
    [System.Management.Automation.PSCredential] $Credential,
    [Parameter(Position=2, ParameterSetName='Plain', Mandatory=$true)]
    [Alias("UserID", "Username")]
    [string] $User,
    [Parameter(Position=3, ParameterSetName='Plain', Mandatory=$true)]
    [string] $Password,
    [Parameter(Position=3, ParameterSetName='Credential', Mandatory=$false)]
    [Parameter(Position=4, ParameterSetName='Plain',      Mandatory=$false)]
    [Alias("ApplicationName")]
    [string] $Application = "Powershell Client",
    [Parameter(Position=4, ParameterSetName='Credential', Mandatory=$false)]
    [Parameter(Position=5, ParameterSetName='Plain',      Mandatory=$false)]
    [string] $Language = 'en-US',             # TODO: Get the current system language
    [Parameter(Position=5, ParameterSetName='Credential', Mandatory=$false)]
    [Parameter(Position=6, ParameterSetName='Plain',      Mandatory=$false)]
    [ValidateSet("http", "https")]
    [string] $Protocol = "http",
    [Parameter(Position=6, ParameterSetName='Credential', Mandatory=$false)]
    [Parameter(Position=7, ParameterSetName='Plain',      Mandatory=$false)]
    [int] $Port = 8018,
    [Parameter(Position=7, ParameterSetName='Credential', Mandatory=$false)]
    [Parameter(Position=8, ParameterSetName='Plain',      Mandatory=$false)]
    [int] $MaxRedirections = 8
  )

  if ($PSCmdlet.ParameterSetName -eq 'Credential')
  {
    Write-Verbose "Loading PSCredentials"
    $User     = $Credential.UserName
    $Password = $Credential.GetNetworkCredential().password
  }
  $auth_settings = @{
    __type          = "urn:inin.com:connection:icAuthConnectionRequestSettings";
    userID          = $User;
    password        = $Password;
    applicationName = $Application;
  } | ConvertTo-JSON
  $headers = @{
    "Accept-Language" = $Language
  }

  if ($Port -eq 8018 -and $Protocol -eq 'https') # TODO: Better check if Port is the default value
  {
    $Port = 8019
  }

  foreach ($redirection in 1 .. $MaxRedirections)
  {
    try
    {
      $url      = "${Protocol}://${ComputerName}:${Port}/icws"
      $response = Invoke-WebRequest -Uri "${url}/connection" -Method Post -ContentType "application/json; charset=utf-8" -Body $auth_settings -Headers $headers -SessionVariable webSession -ErrorAction Stop
      $results  = ConvertFrom-JSON $response
      Write-Verbose "Connected to ${ComputerName} as ${User}"
      Write-Debug "Results: $results"

      $cookie_info = $response.Headers["Set-Cookie"] -replace '(Secure|HttpOnly)(?([,;])|$)','$1=1; '
      $cookie_info = ConvertFrom-StringData ($cookie_info -replace '; ',"`n")
      $cookie = ''
      foreach($key in $cookie_info.Keys)
      {
        if ('version','path','domain','expires','HttpOnly','Secure' -notcontains $key)
        {
          $cookie += "; ${key}=$($cookie_info[$key])"
        }
      }
      $cookie = $cookie.substring(2) # Remove the initial '; '
      Write-Debug "Adding cookie: $cookie to URL: $url"
      $webSession.Cookies.SetCookies($url, $cookie);

      return [ININ.ICSession] @{
        id         = $results.sessionId;
        token      = $results.csrfToken;
        baseUrl    = [System.Uri] $url;
        webSession = $webSession;
        servers    = $results.alternateHostList;
        server     = $results.icServer;
        user       = [ININ.ICUser] @{ id = $results.userID; display = $results.userDisplayName };
        language   = $Language;
      }
    }
    catch [System.Net.WebException]
    {
      if ($_.Exception.Response.StatusCode -ne 'ServiceUnavailable') { Throw $_ }
      if ([string]::IsNullOrEmpty($_.ErrorDetails))                  { Throw $_ }
      try { $details = ConvertFrom-Json $_.ErrorDetails } catch{}
      if ($details -eq $null)                                        { Throw $_ }
      Write-Verbose "$ComputerName error: $($details.message) [$($details.errorId)]"
      if ('error.server.notAcceptingConnections','error.server.unavailable' -notcontains $details.errorId) { Throw $_ }
      if ($details.alternateHostList.Count -eq 0) { Throw $_ }
      $ComputerName = $details.alternateHostList[0]
      Write-Verbose "Next Server to Try: $ComputerName"
    }
  }
  Throw "Unavailable" # TODO: Throw better Exception!
} # }}}2

