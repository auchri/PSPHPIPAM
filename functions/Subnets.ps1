function Get-PhpIpamAllSubnets {
    Get-PhpIpamAllSections | Get-PhpIpamSubnetsBySectionID
}

function Get-PhpIpamSubnetById {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int] $Id
    )

    return $(Invoke-PhpIpamExecute -method get -controller subnets -identifiers @($Id)).data
}

function Get-PhpIpamSubnetUsageByID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method get -controller subnets -identifiers @($ID, "usage")).data
    }

    end {

    }
}

function Get-PhpIpamSubnetFirst_freeByID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method get -controller subnets -identifiers @($ID, "first_free")).data
    }

    end {

    }
}

function Get-PhpIpamSubnetSlavesByID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method get -controller subnets -identifiers @($ID, "slaves")).data
    }

    end {

    }
}

function Get-PhpIpamSubnetSlaves_RecursiveByID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method get -controller subnets -identifiers @($ID, "slaves_recursive")).data
    }

    end {

    }
}

function Get-PhpIpamSubnetAddressesByID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method get -controller subnets -identifiers @($ID, "addresses")).data
    }

    end {

    }
}


function Remove-PhpIpamSubnetByID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method delete -controller subnets -identifiers @($ID)).success
    }

    end {

    }
}


function Remove-PhpIpamSubnetAllAddressBySubnetID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method delete -controller subnets -identifiers @($ID, "truncate")).success
    }

    end {

    }
}

function Remove-PhpIpamSubnetAllPermissionsBySubnetID {
    [cmdletBinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, position = 0)]
        [int]$ID
    )

    begin {
        Write-Verbose $ID
    }
    process {
        return $(Invoke-PhpIpamExecute -method delete -controller subnets -identifiers @($ID, "permissions")).success
    }

    end {

    }
}

function New-PhpIpamSubnet {
    Param(
        [ipaddress] $Subnet,
        [int32] $Mask,
        [int32] $SectionId,
        [string] $Description,
        [int32] $MasterSubnetId,
        [bool] $ShowName,
        [bool] $PingSubnet,
        [bool] $DiscoverSubnet,
        [bool] $ResolveDns,
        [int32] $NameserverId,
        [int32] $ScanAgent,
        [int32] $Threshold
    )

    $params = @{
        'subnet' = $Subnet;
        'mask' = $Mask;
        'description' = $Description;
        'sectionId' = $SectionId;
        'masterSubnetId' = $MasterSubnetId;
        'nameserverId' = $NameserverId;
        'showName' = [int] $ShowName;
        'scanAgent' = $ScanAgent;
        'pingSubnet' = [int] $PingSubnet;
        'discoverSubnet' = [int] $DiscoverSubnet;
        'resolveDNS' = [int] $ResolveDns;
        'threshold' = [int] $Threshold
    }

    return Invoke-PhpIpamExecute -method post -controller subnets -params $params
}

function Update-PhpIpamSubnet {
    [cmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [validatescript( {$_ -is [hashtable] -or $_ -is [psCustomObject]})]
        $Params = @{}
    )
    BEGIN {

    }
    PROCESS {
        return $(Invoke-PhpIpamExecute -method patch -controller subnets -params $Params).success
    }
    END {

    }
}
