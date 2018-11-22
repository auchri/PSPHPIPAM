function Get-PhpIpamDevices {
    return (Invoke-PhpIpamExecute -method get -controller devices).data
}

function Get-PhpIpamDevice([int32] $Id) {
    return (Invoke-PhpIpamExecute -method get -controller tools -identifiers @('devices', $Id)).data
}

function Get-PhpIpamDevicesOfLocation([int32] $LocationId) {
    return (Invoke-PhpIpamExecute -method get -controller tools -identifiers @('locations', $LocationId, 'devices')).data
}

function New-PhpIpamDevice() {
        param (
        [string] $Name,
        [string] $Description,
        [ipaddress] $IpAddress,
        [int32] $Type,
        [string] $SnmpCommunity,
        [int32] $SnmpVersion,
        [int32] $SnmpPort,
        [int32] $SnmpTimeout,
        [string[]] $SnmpQueries,
        [int32] $LocationId,
        [Hashtable] $CustomFields = @{}
    )

    $parameters = @{
        "hostname" = $Name;
        "description" = $Description;
        "ip" = $IpAddress;
        "type" = $Type;
        "snmp_community" = $SnmpCommunity;
        "snmp_version" = $SnmpVersion;
        "snmp_port" = $SnmpPort;
        "snmp_timeout" = $SnmpTimeout;
        "snmp_queries" =  ($SnmpQueries -join ';');
        "location" = $LocationId;
    }

    $parameters += $CustomFields

    return Invoke-PhpIpamExecute -method post -controller devices -params $parameters
}

function Remove-PhpIpamDevice([int32] $Id) {
    return Invoke-PhpIpamExecute -method delete -controller tools -identifiers @('devices', $Id)
}

function Update-PhpIpamDevice() {
        param (
        [int32]  $Id,
        [string] $Name,
        [string] $Description,
        [ipaddress] $IpAddress,
        [int32] $Type,
        [string] $SnmpCommunity,
        [int32] $SnmpVersion,
        [int32] $SnmpPort,
        [int32] $SnmpTimeout,
        [string[]] $SnmpQueries,
        [int32] $LocationId,
        [Hashtable] $CustomFields = @{}
    )



    $existingData = Get-PhpIpamDevice -Id $Id
    $existingData.PsObject.Members.Remove('id') # Remove id
    $existingData.PsObject.Members.Remove('editDate') # Remove editDate

    if($PSBoundParameters.ContainsKey('Name')) {
        $existingData.hostname = $Name
    }

    if($PSBoundParameters.ContainsKey('Description')) {
        $existingData.description = $Description
    }

    if($PSBoundParameters.ContainsKey('IpAddress')) {
        $existingData.ip = $IpAddress
    }

    if($PSBoundParameters.ContainsKey('SnmpCommunity')) {
        $existingData.snmp_community = $SnmpCommunity
    }

    if($PSBoundParameters.ContainsKey('SnmpVersion')) {
        $existingData.snmp_version = $SnmpVersion
    }

    if($PSBoundParameters.ContainsKey('SnmpPort')) {
        $existingData.snmp_port = $SnmpPort
    }

    if($PSBoundParameters.ContainsKey('SnmpTimeout')) {
        $existingData.snmp_timeout = $SnmpTimeout
    }

    if($PSBoundParameters.ContainsKey('SnmpQueries')) {
        $existingData.snmp_queries = ($SnmpQueries -join ';')
    }

    if($PSBoundParameters.ContainsKey('LocationId')) {
        $existingData.location = $LocationId
    }

    if($PSBoundParameters.ContainsKey('CustomFields')) {
        Add-PhpIpamCustomFieldsToExistingData -ExistingData $existingData -CustomFields $CustomFields
    }

    return Invoke-PhpIpamExecute -method patch -controller tools -identifiers @('devices', $Id) -params $existingData
}
