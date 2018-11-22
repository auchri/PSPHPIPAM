function Get-PhpIpamLocations {
    return (Invoke-PhpIpamExecute -method get -controller tools -identifiers @('locations')).data
}

function Get-PhpIpamLocation([int32] $Id) {
    return (Invoke-PhpIpamExecute -method get -controller tools -identifiers @('locations', $Id)).data
}

function New-PhpIpamLocation() {
    param (
        [string] $Name,
        [string] $Description,
        [string] $Address,
        [double] $Lat,
        [double] $Long,
        [Hashtable] $CustomFields = @{}
    )

    # Ensure that double values have a dot instead of , - not handled correctly by phpipam :)
    $parameters = @{"name" = $Name; "description" = $Description; "address" = $Address; "lat" = ($Lat -replace ',', '.'); "long" = ($Long -replace ',', '.') }
    $parameters += $CustomFields

    return Invoke-PhpIpamExecute -method post -controller tools -identifiers @('locations') -params $parameters
}

function Remove-PhpIpamLocation([int32] $Id) {
    return Invoke-PhpIpamExecute -method delete -controller tools -identifiers @('locations', $Id)
}

function Update-PhpIpamLocation() {
    param (
        [int32]  $Id,
        [string] $Name,
        [string] $Description,
        [string] $Address,
        [double] $Lat,
        [double] $Long,
        [Hashtable] $CustomFields = @{}
    )
    
    $existingData = Get-PhpIpamLocation -Id $Id
    $existingData.PsObject.Members.Remove('id') # Remove id

    if($PSBoundParameters.ContainsKey('Name')) {
        $existingData.name = $Name
    }

    if($PSBoundParameters.ContainsKey('Description')) {
        $existingData.description = $Description
    }

    if($PSBoundParameters.ContainsKey('Address')) {
        $existingData.address = $Address
    }

    if($PSBoundParameters.ContainsKey('Lat')) {
        $existingData.lat = ($Lat -replace ',', '.')
    }

    if($PSBoundParameters.ContainsKey('Long')) {
        $existingData.long = ($Long -replace ',', '.')
    }

    if($PSBoundParameters.ContainsKey('CustomFields')) {
        Add-PhpIpamCustomFieldsToExistingData -ExistingData $existingData -CustomFields $CustomFields
    }

    return Invoke-PhpIpamExecute -method patch -controller tools -identifiers @('locations', $Id) -params $existingData
}
