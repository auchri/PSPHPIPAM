function Get-PhpIpamAddressesByID{
    [cmdletBinding()]
    Param(
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0)]
         [int]$ID
    )

    begin{

    }
    process{
            return $(Invoke-PhpIpamExecute -method get -controller addresses -identifiers @($ID)).data

    }

    end{

    }
}

function Get-PhpIpamAddressesByIP{
    [cmdletBinding()]
    Param(
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0)]
         [string]$IP
    )

    begin{

    }
    process{
            return $(Invoke-PhpIpamExecute -method get -controller addresses -identifiers @("search",$IP)).data

    }

    end{

    }
}


function Get-PhpIpamAddresses{
    [cmdletBinding()]
    Param(
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0,ParameterSetName="IP")]
         [string]$IP,

         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0,ParameterSetName="ID")]
         [int]$ID
    )

    begin{

    }
    process{
            if ($PsCmdlet.ParameterSetName -eq "IP"){
                return $(Invoke-PhpIpamExecute -method get -controller addresses -identifiers @("search",$IP)).data
            }

            if($PsCmdlet.ParameterSetName -eq 'ID'){

                return $(Invoke-PhpIpamExecute -method get -controller addresses -identifiers @($ID)).data
            }

    }

    end{

    }
}

function Update-PhpIpamAddressById{
    [cmdletBinding()]
    Param(
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0)]
         [string]$Id,

         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
         $Params
    )
    
    begin{

    }
    process{
            return $(Invoke-PhpIpamExecute -method patch -controller addresses -identifiers @($Id) -params $Params).data

    }

    end{

    }
}

function New-PhpIpamAddress{
    [cmdletBinding()]
    Param(
     [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      $Params
    )
    
    return $(Invoke-PhpIpamExecute -method post -controller addresses  -params $params).success
}

function Search-PhpIpamAddressByHostname{
 #/api/my_app/addresses/search_hostname/{hostname}/
    [cmdletBinding()]
    Param(
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0)]
         [string]$hostname
    )
    
    begin{

    }
    process{
            return $(Invoke-PhpIpamExecute -method get -controller addresses -identifiers @("search_hostname",$hostname)).data

    }

    end{

    }
}

function Search-PhpIpamAddress {
 #/api/my_app/addresses/search/{ip}/
    [cmdletBinding()]
    Param(
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0)]
         [string] $IpAddress
    )

    $Data = Invoke-PhpIpamExecute -method get -controller addresses -identifiers @('search', $IpAddress)
    
    if($Data.success -ne $true) {
        return $null
    }

    return $Data.data
}
