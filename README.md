# Powershell REST client module for PHPIPAM

Powershell module with support for the new API mode comming in phpIpam.

### Examples

``` powershell
# Using token auth (AppId + AppCode)
New-PhpIpamSession -useAppKeyAuth -PhpIpamApiUrl $Url -AppID $AppId -AppKey $AppKey

# Get all sections
Get-PhpIpamAllSections

# or:
Invoke-PhpIpamExecute -method get -controller sections

# /api/my_app/sections/{id}/	Returns specific section ,id=1
Invoke-PhpIpamExecute -method get -controller sections -identifiers @(1)
Get-PhpIpamSectionsByID -ID 1

# /api/my_app/sections/{id}/subnets/	Returns all subnets in section
Invoke-PhpIpamExecute -method get -controller sections -identifiers @(1,'subnets')

# /api/my_app/sections/{name}/	Returns specific section by name
Invoke-PhpIpamExecute -method get -controller sections -identifiers @('ipv6')

```

### How to Debug
The functions in this module mainly used powershell advanced function feature (the function which contains `[cmdletbinding()]`, so when you encounter errors ,you can add the `-debug` switch to see what's goging on there,you can add your `write-debug ` expression to the function to see more information if you want.


like this
``` powershell
New-PhpIpamSession -useCredAuth -PhpIpamApiUrl http://127.0.0.1/api -AppID script2 -userName admin -password password -debug
```
