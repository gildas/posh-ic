# posh-ic

Powershell module to connect to an Interaction Center over ICWS.

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
>If a userId is not passed, it will use the currently logged on user

**Get all users**
```posh
Get-ICUsers $cic
```
**Gets a user**
```posh
Get-ICUser $cic
Get-ICUser $cic -UserId 'agent001'
```
>If a userId is not passed, it will use the currently logged on user

**Create a new user**
```posh
New-ICUser $cic -UserId 'agent001'
New-ICUser $cic -UserId 'agent001' -Password '1234'
New-ICUser $cic -UserId 'agent001' -Password '1234' -Extension '8001'
```
>If the password ommitted, it will be set to '1234'

**Delete a user**
```posh
Remove-ICUser $cic -UserId 'agent001'
```

### Workgroups Functions

**Get all workgroups**
```posh
Get-ICWorkgroups $cic
```

**Get Workgroup**
```posh
Get-ICWorkgroup $cic -WorkgroupId 'workgroup001'
```

**Create a new workgroup**
```posh
New-ICWorkgroup $cic -WorkgroupId 'workgroup001'
New-ICWorkgroup $cic -WorkgroupId 'workgroup001' -HasQueue true -QueueType 'ACD' -IsActive true
New-ICWorkgroup $cic -WorkgroupId 'workgroup001' -Extension '9010'
New-ICWorkgroup $cic -WorkgroupId 'workgroup001' -Extension '9010' -Members @('agent001', 'agent002')
```
* Default values:
    * HasQueue: true
    * QueueType: 'ACD'
    * IsActive: true
> All parameters except WorkgroupIp are optional parameters

**Remove a workgroup**
```posh
Remove-ICWorkgroup $cic -WorkgroupId 'workgroup001'
```