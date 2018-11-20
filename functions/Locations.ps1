function Get-PhpIpamAllLocations{
    return (Invoke-PhpIpamExecute -method get -controller tools -identifiers @('locations')).data
}