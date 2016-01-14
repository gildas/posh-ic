# posh-ic

Powershell module to connect to an Interaction Center over ICWS.

## Installing via PowerShellGet

If you have [PowerShellGet](https://www.powershellgallery.com) installed (Windows 10 has it by default), just run:

```posh
Install-Module posh-ic
```

## Installing via PsGet

If you have [PsGet](https://psget.net) installed, just run:

```posh
Install-Module posh-ic
```

## HowTo

Import the Posh-IC module in your script

```posh
Import-Module .\lib\Posh-IC.psm1
```

Then use one of the existing functions

## Functions

### Session functions
**Connect to CIC**
```posh
$cic = New-ICSession -ComputerName cic.acme.com -User admin -Password '1234'
```
>Use the returned session in your future API calls

**Get the session status**
```posh
Get-ICSessionStatus $cic
```

**Disconnect from CIC**
```posh
Remove-ICSession $cic
```

### User Functions
**Get a user status**
```posh
Get-ICUserStatus $cic
Get-ICUserStatus $cic 'agent001'
```
>If a user id is not passed, it will use the currently logged on user

**Get all users**
```posh
Get-ICUsers $cic
```
**Gets a user**
```posh
Get-ICUser $cic
Get-ICUser $cic -User 'agent001'
```
>If a user id is not passed, it will use the currently logged on user

**Create a new user**
```posh
New-ICUser $cic -User 'agent001'
New-ICUser $cic -User 'agent001' -Password '1234'
New-ICUser $cic -User 'agent001' -Password '1234' -Extension '8001'
```
>If the password ommitted, it will be set to '1234'

**Delete a user**
```posh
Remove-ICUser $cic -User 'agent001'
```

### Workgroups Functions

**Get all workgroups**
```posh
Get-ICWorkgroups $cic
```

**Get Workgroup**
```posh
Get-ICWorkgroup $cic -Workgroup 'workgroup001'
```

**Create a new workgroup**
```posh
New-ICWorkgroup $cic -Workgroup 'workgroup001'
New-ICWorkgroup $cic -Workgroup 'workgroup001' -HasQueue true -QueueType 'ACD' -IsActive true
New-ICWorkgroup $cic -Workgroup 'workgroup001' -Extension '9010'
New-ICWorkgroup $cic -Workgroup 'workgroup001' -Extension '9010' -Members @('agent001', 'agent002')
```
* Default values:
    * HasQueue: true
    * QueueType: 'ACD'
    * IsActive: true
> All parameters except WorkgroupIp are optional parameters

**Remove a workgroup**
```posh
Remove-ICWorkgroup $cic -Workgroup 'workgroup001'
```
