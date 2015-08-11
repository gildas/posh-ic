posh-ic
=======

Powershell module to connect to an Interaction Center over ICWS.

Examples
========

```posh
Import-Module Posh-IC

$cic = New-ICSession -ComputerName cic.acme.com -User admin -Password '1234'

Get-ICSessionStatus $cic

Get-ICUserStatus $cic

Get-ICUserStatus $cic 'agent001'

Remove-ICSession $cic
```
