function Add-PhpIpamCustomFieldsToExistingData([psobject] $ExistingData, [hashtable] $CustomFields) {
    foreach ($key in $CustomFields.Keys) {
        $value = $CustomFields.Item($key)

        if(([bool]($existingData.PSobject.Properties.name -match $key))) {
            $existingData.$key = $value
        } else {
            $existingData | Add-Member -MemberType NoteProperty -Name $key -Value $value
        }
    }
}

function Get-PhpIpamUrl {

   <#
     .DESCRIPTION
      Builds the url for the calls
      
      .PARAMETER $PhpIpamApiUrl
      url which phpipam use for example http://ipam/api/

      .PARAMETER $AppID
      the AppID of using the API.

      .PARAMETER $Controller
      the controller of the api

      .PARAMETER $Identifiers
      the identifiers array

  #>
    param(
        
        [parameter(mandatory=$true, HelpMessage="Enter the Api Url of IppIpam")]
        [validateScript({$_.startswith("http")})]
        [string] $PhpIpamApiUrl,

        [parameter(mandatory=$true, HelpMessage="Enter the AppID of PhpIpam")]
        [string] $AppID,

        [parameter(mandatory=$true, HelpMessage="Enter the controller of the api")]
        [string] $Controller,

        [parameter(mandatory=$false,HelpMessage="Enter the identifiers array")]
        [array]$Identifiers=@()
    )    
    
    if($Identifiers.Count -gt 0) {
        $parameters = (($identifiers -join '/')+'/')
    } else {
        $parameters = ''
    }

    return "{0}/{1}/{2}/{3}" -f $PhpIpamApiUrl,$AppID, $Controller, $parameters
}

function Invoke-PhpIpamExecute{

   <#
     .DESCRIPTION
      invoke-PhpIpamExecute using stored vars to invoke PhpIpamApi, if you can using username and password token based auth ,or you can use
      Appid and AppKey based Encrypt request.

      .PARAMETER $method
      Http Method you want use ("get","put","options","patch","post","delete")

      .PARAMETER $AppKey
      AppKey for phpipam

      .PARAMETER $controller
      Api Endpoint you want use ,which can be one of such set
      ("sections","subnets","folders","addresses","vlans","l2domains","vfr","tools","prefix")

      .PARAMETER $identifiers
      Array to idenfify a resource
      if the api url is  /api/my_app/sections/{id}/subnets/, the identifiers array will be @(4,'subnets'), 4 is the section which id is 4

      .PARAMETR $params
      Hashtable to specify the query string. if the api url you want query is  /api/my_app/sections/ and then you specify @{id=1} as $params
      the result with return just one section which id is 1.

      .PARAMETER $headers
      you can specify you own headers here.
      
      .EXAMPLE
      invoke-PHPIpamExecute -method get  -controller sections 

      .EXAMPLE
      /api/my_app/sections/
      invoke-PHPIpamExecute -method get   -controller sections

      .EXAMPLE
      /api/my_app/sections/?id=4
      invoke-PHPIpamExecute -method get  -controller sections -params @{id=10}

      .EXAMPLE
      /api/my_app/sections/4
      invoke-PHPIpamExecute -method get  -controller sections -identifiers @(4)

  #>
   param(
        [parameter(mandatory=$true,HelpMessage="Enter the API method")]
        [validateSet("get","put","options","patch","post","delete")]
        [string]$method="get",

        [parameter(mandatory=$true,HelpMessage="Enter the controller (API Endpoint)")]
        [validateSet("user", "devices", "tools")]
        [alias('Endpoint')]
        [string]$controller="sections",

        [parameter(mandatory=$false,HelpMessage="Enter the identifiers array")]
        [array]$identifiers=@(),

        [parameter(mandatory=$false,HelpMessage="Enter the params hashtable")]
        [validateScript({$_ -is [hashtable] -or $_ -is [psCustomObject]})]
        $params=@{},
        
        [parameter(mandatory=$false,HelpMessage="Enter the params hashtable")]
        [validateScript({$_ -is [hashtable]})]
        $headers=@{}

    )

    # lowercase controller
    $controller=$controller.ToLower()
    if($params -is [psCustomObject]){
        $params=$params|ConvertTo-HashtableFromPsCustomObject
    }

    if($global:phpipamTokenAuth -eq $true) {
            Write-Debug "Using TokenAuth,Test Token Status"
            $ipamstatus=test-PhpIpamToken
            if($ipamstatus -eq 'Expired'){
                Write-Debug "Token status is Expired"
                expand-PhpIpamTokenLife -force
            }

            # get token status again
            $ipamstatus=test-PhpIpamToken

            # build uri which using token auth
            if($ipamstatus -eq 'valid'){
               $uri=$((@($Global:PhpipamAppID,$controller)+$identifiers) -join "/") +"/"
               $uri=$Global:PhpipamApiUrl +"/" +$uri.Replace("//","/")
            }

            if($ipamstatus -eq 'notoken'){
                throw 'No Token can be used,please use new-PhpIpamSession command first to get token'
            }

            # build headers
            if(!$headers -or $headers.count -eq 0){
                $headers=@{
                    token=$global:phpipamToken
                }
            }elseif($headers -and $headers.count -gt 1){
                if(!$headers.Contains("token")){
                    $headers.Add("token",$global:phpipamToken)
                }
            }
        } else {
        # check whether Global AppID and APPkey exist
        if($Global:PhpipamAppID -and $Global:PhpipamAppKey){
            $uri = Get-PhpIpamUrl -PhpIpamApiUrl $Global:PhpipamApiUrl -AppID $Global:PhpipamAppID -Controller $controller -Identifiers $identifiers
            $headers.Add("token",$global:PhpIpamAppKey)
        }else{
            throw "No AppID and AppKey can be used,please use new-PhpIpamSession command first to check and store AppID and AppKey"
        }
    }

    if($global:phpipamTokenAuth -eq $null){
        throw "No Auth Method exist,please use new-PhpIpamSession command first to specify auth method and infos"
    }    
                
    try{
        $r = Invoke-RestMethod -Method $method -Headers $headers  -Uri $uri -body $params

        if($r -ne $null -and $r -is [System.Management.Automation.PSCustomObject]){
            return $r
        }else{
            # to process unvliad json output like this
            # <div class='alert alert-danger'>Error: SQLSTATE[23000]: Integrity constraint violation: 1048 Column 'cuser' cannot be null</div>{"code":201,"success":true,"data":"Section created"}
            if($r -ne $null -and $r -is [System.String]){
                $objmatch=([regex]'(\{\s*"code"\s*:\s*(.+?)\s*.+?\})').Match($r)
                if($objmatch.Success){
                    try{
                        $r = ConvertFrom-Json -InputObject $objmatch.Groups[1].Value -ErrorAction Stop
                        return $r
                    }catch{
                        throw $("Can not parse the output [" + $r +']')
                    }
                }else{
                    throw $("Can not parse the output [" + $r +']')
                }
            }
        }
    } catch {
        throw $_.ErrorDetails.message
    }
}

function Remove-PhpIpamSession{

  <#
     .DESCRIPTION
      Clears the globally set credentials. Use at the end of a session or automation script. Takes no args. 

      .EXAMPLE
      Remove-phpipamSession
  #>

  $global:PhpIpamUsername =$null
  $global:PhpIpamPassword =$null
  $global:PhpIpamApiUrl =$null
  $global:PhpIpamAppID=$null
  $global:PhpIpamAppKey=$null
  $global:PhpIpamToken=$null
  $global:PhpIpamTokenExpires=$null
  $global:PhpIpamTokenAuth=$null

  return $true
}

function New-PhpIpamSession{

   <#
     .DESCRIPTION
      Defines global variables (PhpIpam top url,AppID,username, and password) so they do not have to be explicitly defined for subsequent calls.
      If you do not define any switches, New-PhpIpamSession will prompt you for credentials. This is best for an interactive session.


      .PARAMETER $PhpIpamApiUrl
      url which phpipam use for example http://ipam/api/

      .PARAMETER $UseCredAuth
      switch to use username and password (token based auth)

      .PARAMETER UseAppKeyAuth
      switch to use Appid and Appkey (encrypt request)

      .PARAMETER $AppID
      the AppID of using the API.

      .PARAMETER $AppKey
      AppKey for phpipam

      .PARAMETER $Username
      Username for phpipam

      .PARAMETER $Password
      Password for phpipam

      .EXAMPLE
      New-PhpIpamSession -userCredAuth 

      .EXAMPLE
      New-PhpIpamSession -useCredAuth -phpIpamApiUrl http://ipam/api/ -username username -password password -appid script

      .EXAMPLE
      New-PhpIpamSession -useAppKeyAuth -PhpIpamApiUrl http://ipam/api/ -appid 'script' -appkey 'de36328dbe3df0bc7d39ff2306e9aesa'

  #>
        param(

        [parameter(mandatory=$true,ParameterSetName="UseCredAuth",HelpMessage="switch to using name and password auth")]
        [switch]
        $useCredAuth,

        [parameter(mandatory=$true,ParameterSetName="UseAppKeyAuth",HelpMessage="switch to using AppID and AppKey auth")]
        [switch]
        $useAppKeyAuth,

        [parameter(mandatory=$true, HelpMessage="Enter the Api Url of IppIpam")]
        [validatescript({$_.startswith("http")})]
        [string]$PhpIpamApiUrl,

        [parameter(mandatory=$true,ParameterSetName="UseCredAuth", HelpMessage="Enter the AppID of PhpIpam")]
        [parameter(mandatory=$true,ParameterSetName="UseAppKeyAuth", HelpMessage="Enter the AppID of PhpIpam")]
        [string]$AppID,

        [parameter(mandatory=$true,ParameterSetName="UseAppKeyAuth", HelpMessage="Enter the AppKey of PhpIpam")]
        [validatepattern("^[0-9a-fA-f]{32}$")]
        [string]$AppKey,

        [parameter(mandatory=$true,ParameterSetName="UseCredAuth", HelpMessage="Enter the Username of PhpIpam.")]
        [string]$userName,

        [parameter(mandatory=$true,ParameterSetName="UseCredAuth", HelpMessage="Enter The password of PhpIpam.")]
        [string]$password

        )

        if($PhpIpamApiUrl.EndsWith("/")){
            $PhpIpamApiUrl=$PhpIpamApiUrl.TrimEnd("/")
        }

        if($useCredAuth){
            $token="{0}:{1}" -f $username,$password
            $base64Token=[convert]::ToBase64String([char[]]$token)

            $headers=@{
                        Authorization="Basic {0}" -f $base64Token
            }
            $uri="{0}/{1}/user/" -f $PhpIpamApiUrl,$AppID

            try{
                $r=Invoke-RestMethod -Method post -Uri $uri -Headers $headers
                if($r -and $r.success){
                # success

                    $global:PhpIpamUsername =$username
                    $global:PhpIpamPassword =$password
                    $global:PhpIpamApiUrl =$PhpIpamApiUrl
                    $global:PhpIpamAppID=$AppID
                    $global:PhpIpamToken=$r.data.token
                    $global:PhpIpamTokenExpires=$r.data.expires
                    $global:PhpIpamTokenAuth=$true
                    return $true
                }else{
                    Write-Error "Something error there"
                    return $false
                }
            }catch{
                write-error $_.ErrorDetails.message
                return $false
            }
        }

        if($useAppKeyAuth){
            $uri = Get-PhpIpamUrl -PhpIpamApiUrl $PhpIpamApiUrl -AppID $AppID -Controller 'user'
            
            try {
                Invoke-RestMethod -Method get -Uri $uri -Headers @{'Token' = $AppKey}
            } catch {
                if($_.Exception.Response.StatusCode.value__ -eq 409) { # Key is valid
                    $global:PhpIpamApiUrl =$PhpIpamApiUrl
                    $global:PhpIpamAppID=$AppID
                    $global:PhpIpamAppKey=$AppKey
                    $global:PhpIpamTokenAuth=$false
                    return $true
                }

                write-error $_.ErrorDetails.message
                return $false 
            }
        }

        return $false
}

function Test-PhpIpamToken{
    <#
         .DESCRIPTION
         after you succefully called new-phpipamSession ,the global param was set. then test-phpipam use the saved params to test whether token is expired.

         .Example
         test-PhpIpamToken
    #>
    if(!$Global:PhpIpamTokenAuth){
        Write-Warning "Because you use encrypted request(You never get a token,Do not use this func if you using encryped request)"
        return "Valid"
    }else{
        if($global:PhpIpamTokenExpires){
            if($global:PhpIpamTokenExpires -lt $(get-date)){
                return "Expired"
            }else{
                return "Valid"
            }
        }else{
            return "NoToken"
        }
    }

}

function Expand-PhpIpamTokenLife{
param(
    [switch]$force
)
    if($Global:PhpIpamTokenAuth){
        if(!$force){
            $TokenStatus=test-PhpIpamToken
            if($Tokenstatus -eq "Valid"){
                $r=invoke-PHPIpamExecute -method patch -controller user
                if($r){
                    $global:PhpIpamTokenExpires=$r.data.expires
                    return $r.data.expires
                }
            }
        }
        if($TokenStatus -eq "Expired" -or $force){
            if(New-PhpIpamSession -useCredAuth -PhpIpamApiUrl $global:PhpIpamApiUrl -AppID $Global:PhpIpamAppID -userName $global:PhpIpamUsername -password $global:PhpIpamPassword){
                return $global:PhpIpamTokenExpires
            }
        }
    }else{
        Write-Warning "Because you use encrypted request(You never get a token,Do not use this func if you using encryped request)"
    }
}

function Convert-IdentifiersArrayToHashTable{
    param(
        [parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [object[]]
        $Identifiers
      )
    $output=@{}
    For($i=0;$i -lt $Identifiers.Count;$i++){
        if($i -eq 0){
            $output.Add("id",$Identifiers[$i])
        }else{
            $output.add("id$($i+1)",$Identifiers[$i])
        }
    }
    return $output
   }


   function ConvertTo-PsCustomObjectFromHashtable { 
     param ( 
         [Parameter(  
             Position = 0,   
             Mandatory = $true,   
             ValueFromPipeline = $true,  
             ValueFromPipelineByPropertyName = $true  
         )][hashtable] $hashtable 
     ); 
     
     begin { $i = 0; } 
     
     process {
        return $([PSCustomObject]$hashtable )
     } 
}
function ConvertTo-HashtableFromPsCustomObject { 
     param ( 
         [Parameter(  
             Position = 0,   
             Mandatory = $true,   
             ValueFromPipeline = $true,  
             ValueFromPipelineByPropertyName = $true  
         )] $inputObject 
     ); 
     
     process { 
            $output = @{}; 
            $inputObject | Get-Member -MemberType *Property | % { 
                $output.($_.name) = $inputObject.($_.name); 
            } 
            return $output;  
     } 
}