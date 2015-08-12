$AssemblyPath = New-Item -Force -ItemType Directory -Path ([io.path]::combine($env:AppData, 'Interactive Intelligence', 'Posh-IC'))

$TypeName = 'ININ.ConnectionState' # {{{
if (-not ([System.Management.Automation.PSTypeName] $TypeName).Type)
{
  $TypeAssembly = Join-Path $AssemblyPath "${TypeName}.dll"
  Add-Type -OutputAssembly $TypeAssembly -OutputType Library -TypeDefinition @'
  namespace ININ
  {
    public enum ConnectionState
    {
      None,
      Up,
      Dowm
    };
  }
'@
  [System.Reflection.Assembly]::LoadFile($TypeAssembly) | Out-Null
  Write-Verbose "Added New Type: $TypeName"
} # }}}

$TypeName = 'ININ.ICUser' # {{{
if (-not ([System.Management.Automation.PSTypeName] $TypeName).Type)
{
  $TypeAssembly = Join-Path $AssemblyPath "${TypeName}.dll"
  Add-Type -OutputAssembly $TypeAssembly -OutputType Library -TypeDefinition @'
  using System;
  using System.Management.Automation;

  namespace ININ
  {
    public class ICUser
    {
      public string id      { get; set; }
      public string display { get; set; }
    };

    public class ICUserConverter : PSTypeConverter
    {
      public override bool CanConvertFrom(Object p_source, Type p_type)
      {
        return (p_source as string) != null;
      }

      public override object ConvertFrom(object p_source, Type p_type, IFormatProvider p_provider, bool p_ignore_case)
      {
        if (p_source == null) throw new InvalidCastException("no conversion possible");
        if (CanConvertFrom(p_source, p_type))
        {
          try
          {
            string value  = p_source as string;
            ICUser icuser = new ICUser { id = value, display = value };

            return icuser;
          }
          catch(Exception)
          {
            throw new InvalidCastException("no conversion possible");
          }
        }
        throw new InvalidCastException("no conversion possible");
      }
      
      public override bool CanConvertTo(Object p_source, Type p_type)
      {
        return p_type == typeof(string);
      }

      public override object ConvertTo(object p_source, Type p_type, IFormatProvider p_provider, bool p_ignore_case)
      {
        if (CanConvertFrom(p_source, p_type))
        {
          try
          {
            ICUser icuser = p_source as ICUser;

            return icuser.id;
          }
          catch(Exception)
          {
            throw new InvalidCastException("no conversion possible");
          }
        }
        throw new InvalidCastException("no conversion possible");
      }
    }
  }
'@
  [System.Reflection.Assembly]::LoadFile($TypeAssembly) | Out-Null
  Update-TypeData -TypeName $TypeName -TypeConverter "${TypeName}Converter"
  Write-Verbose "Added New Type: $TypeName"
} # }}}

$TypeName='ININ.ICSession' # {{{
if (-not ([System.Management.Automation.PSTypeName] $TypeName).Type)
{
  $TypeAssembly = Join-Path $AssemblyPath "${TypeName}.dll"
  $refs = (Join-Path $AssemblyPath 'ININ.ICUser.dll'), 'Microsoft.Powershell.Commands.Utility'
  Add-Type -OutputAssembly $TypeAssembly -OutputType Library -ReferencedAssemblies $refs -TypeDefinition @'
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
'@
  [System.Reflection.Assembly]::LoadFile($TypeAssembly) | Out-Null
  Write-Verbose "Added New Type: $TypeName"
} # }}}
