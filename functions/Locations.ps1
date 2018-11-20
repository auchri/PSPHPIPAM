function Get-PhpIpamAllLocations {
    return (Invoke-PhpIpamExecute -method get -controller tools -identifiers @('locations')).data
}

function New-PhpIpamLocation() {
    param (
        [string] $Name,
        [string] $Description,
        [string] $Address,
        [double] $Lat,
        [double] $Long
    )

    # Ensure that double values have a dot instead of , - not handled correctly by phpipam :)
    $parameters = @{"name" = $Name; "description" = $Description; "address" = $Address; "lat" = ($Lat -replace ',', '.'); "long" = ($Long -replace ',', '.') }
    $response = Invoke-PhpIpamExecute -method post -controller tools -identifiers @('locations') -params $parameters

    return $response.success
}
