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
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]
    [Alias("ICServer", "Server", "Notifier")]
    [string] $ComputerName,
    [Parameter(Mandatory=$false)]
    [Alias("ApplicationName")]
    [string] $Application = "Powershell Client",
    [Parameter(Mandatory=$true)]
    [Alias("UserID", "Username")]
    [string] $User,
    [Parameter(Mandatory=$true)]
    [string] $Password,
    [Parameter(Mandatory=$false)]
    [string] $Language = 'en-US',             # TODO: Get the current system language
    [Parameter(Mandatory=$false)]
    [ValidateSet("http", "https")]
    [string] $Protocol = "http",
    [Parameter(Mandatory=$false)]
    [int] $Port = 8018
  )

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
  $url      = "${Protocol}://${ComputerName}:${Port}/icws"
  $response = Invoke-WebRequest -Uri "${url}/connection" -Method Post -ContentType "application/json; charset=utf8" -Body $auth_settings -Headers $headers -SessionVariable webSession -ErrorAction Stop
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

  [ININ.ICSession] @{
    id         = $results.sessionId;
    token      = $results.csrfToken;
    baseUrl    = [System.Uri] $url;
    webSession = $webSession;
    servers    = $results.alternateHostList;
    server     = $results.icServer;
    user       = [ININ.ICUser] @{ id = $results.userID; display = $results.userDisplayName };
    language   = $Language;
  }
} # }}}2

