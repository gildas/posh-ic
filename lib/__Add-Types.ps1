$AssemblyPath = New-Item -Force -ItemType Directory -Path ([io.path]::combine($env:AppData, 'Interactive Intelligence', 'Posh-IC'))

if (-not ([System.Management.Automation.PSTypeName] 'ININ.ConnectionState').Type)
{
  $PoshICAssembly = Join-Path $AssemblyPath 'ININ.ConnectionState.dll'
  Add-Type -OutputAssembly $PoshICAssembly -OutputType Library -TypeDefinition @'
  namespace ININ
  {
    public enum ConnectionState
    {
      None,
      Up,
      Dowm
    };
  }
'@ | Out-Null

  [System.Reflection.Assembly]::LoadFile($PoshICAssembly)
}

if (-not ([System.Management.Automation.PSTypeName] 'ININ.ICUser').Type)
{
  $PoshICAssembly = Join-Path $AssemblyPath 'ININ.ICUser.dll'
  Add-Type -OutputAssembly $PoshICAssembly -OutputType Library -TypeDefinition @'
  namespace ININ
  {
    public class ICUser
    {
      public string id      { get; set; }
      public string display { get; set; }
    };
  }
'@ | Out-Null

  [System.Reflection.Assembly]::LoadFile($PoshICAssembly)
}

if (-not ([System.Management.Automation.PSTypeName] 'ININ.ICSession').Type)
{
  $PoshICAssembly = Join-Path $AssemblyPath 'ININ.ICSession.dll'
  $refs = (Join-Path $AssemblyPath 'ININ.ICUser.dll'), 'Microsoft.Powershell.Commands.Utility'
  Add-Type -OutputAssembly $PoshICAssembly -OutputType Library -ReferencedAssemblies $refs -TypeDefinition @'
  using ININ;
  using Microsoft.PowerShell.Commands;

  namespace ININ
  {
    public class ICSession
    {
      public string   id         { get; set; }
      public string   token      { get; set; }
      public string   baseUrl    { get; set; }
      public string   server     { get; set; }
      public string[] servers    { get; set; }
      public ICUser   user       { get; set; }
      public string   language   { get; set; }
      public Microsoft.PowerShell.Commands.WebRequestSession webSession { get; set; }
    };
  }
'@ | Out-Null

  [System.Reflection.Assembly]::LoadFile($PoshICAssembly)
}
