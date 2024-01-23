Function Connect-NetboxAPI {
    <#
    .SYNOPSIS
    Connect to the Netbox API
    
    .DESCRIPTION
    Connect to the Netbox API and generate a Token variable that can be used with your own Invoke-RestMethod commands '$netboxAuthenticationHeader'
    All Functions within this Module already has this variable implemented.
    For the connection verification your API account need access to read /api/dcim/devices/, this is used to verify that you have a valid connection to the API. (it only retrieves 1 device for the verification)
    
    .PARAMETER Url
    Your Netbox Url
    
    .PARAMETER Token
    Your API Token
    
    .PARAMETER LogToFile
    Connect to PSLoggingFunctions module, read more on GitHub, it create a Log folder in your directory if set to True
    
    .EXAMPLE
    Connect-NetboxAPI -Url "https://netbox.internal.local" -Token se651bsb651sdf132adsfg1asd65f46b5 -LogToFile $True
    
    OUTPUT
    Netbox Authenticated: True
    Use Header Connection Variable = $netboxAuthenticationHeader
    #>
    Param(
        [parameter(mandatory)]
        $Url,
        [parameter(mandatory)]
        $Token,
        [parameter(mandatory)]
        $LogToFile
    )
    $netboxAuthenticationHeader = @{
        "Authorization" = "Token "+$Token
        "Accept" = "application/json; indent=4" 
    }

    Write-Log -Message "Connecting to Netbox API" -Active $LogToFile

    $testConnection = Invoke-RestMethod -Method GET -Uri "$Url/api/dcim/devices/?limit=1" -Headers $netboxAuthenticationHeader
    $global:NetboxAuthenticated = $false
    if ($testConnection){
        $global:NetboxAuthenticated = $true
        Write-Log -Message "Netbox Authenticated: $NetboxAuthenticated" -Active $LogToFile
        Write-Host "Netbox Authenticated: $NetboxAuthenticated`nUse Header Connection Variable ="'$netboxAuthenticationHeader'
        $global:netboxAuthenticationHeader = $netboxAuthenticationHeader
        return ""
    }
    Write-Log -Message "Netbox Authenticated: $NetboxAuthenticated" -Active $LogToFile
    Write-Host "Netbox Authenticated: $NetboxAuthenticated"
    return $false
}

Function Find-NetboxConnection {
    if (!$NetboxAuthenticated) {
        Write-Warning "Netbox API is not authenticated, you need to run Connect-NetboxAPI and make sure you put in the correct token!"
        return $false
    }
    return $true
}

Function Get-NetboxObjects {
    <#
    .SYNOPSIS
    Retrieve any Netbox Objects
    
    .DESCRIPTION
    You can retrieve any Netbox Objects through the API by supplying the parameter APIEndpoint with the sort of objects you want to retrieve.
    
    .PARAMETER Url
    Your Netbox Url
    
    .PARAMETER APIEndpoint
    The APIEndpoint (look in Netbox official API) it looks like this example: '/api/dcim/devices/'
    
    .PARAMETER LogToFile
    Connect to PSLoggingFunctions module, read more on GitHub, it create a Log folder in your directory if set to True
    
    .EXAMPLE
    This retrieves all Dcim Devices and Gives you a log in the script root directory
    Get-NetboxObjects -Url "https://netbox.internal.local" -APIEndpoint "/api/dcim/devices/" -LogToFile $True
    
    #>
    Param(
        [parameter(mandatory)]
        $Url,
        [parameter(mandatory)]
        $APIEndpoint,
        [parameter(mandatory)]
        [ValidateSet("True","False")]
        $LogToFile
    )
    if (Find-NetboxConnection){
        $Devices = @()
        $uri = "$($Url)$($APIEndpoint)?limit=0"
        do {
            $uri = $uri -replace("http://","https://")
            $Results = Invoke-TryCatchLog -InfoLog "Retrieving 1000 Netbox Objects from Endpoint: $APIEndpoint" -LogToFile $LogToFile -ScriptBlock {
                Invoke-RestMethod -Uri $uri -Method GET -Headers $netboxAuthenticationHeader -ContentType "application/json"
            }
            if ($Results.results) {
                $Devices += $Results.results
            }
            else {
                $Devices += $Results
            }
            $uri = $Results.next
        } until (!($uri))
        return $Devices
    }
}

Function New-NetboxTenant {
    <#
    .SYNOPSIS
    Create a new netbox tenant (customer)
    
    .DESCRIPTION
    Create new tenants, include tags or other object data if needed.
    
    .PARAMETER Url
    Your netbox Url
    
    .PARAMETER tenantName
    Name of the new Tenant (customer)
    
    .PARAMETER objectData
    If you have other data you want to add as well.
    You supply it like a normal powershell object
    Example:
    -objectData @{custom_fields=@{customer_id = "CUSTOMERID"}}
    
    .PARAMETER tags
    If you have any tags you want to add, it is in a string array
    -tags ("Tag1","Tag2")
    
    .PARAMETER LogToFile
    Connect to PSLoggingFunctions module, read more on GitHub, it create a Log folder in your directory if set to True
    
    .EXAMPLE
    # If you want to add something to the customer value that does not already exist, for example a customer id.
    $customAddition = @{
        custom_fields = @{
            customer_id = "123123"
        }
    }

    New-NetboxTenant -Url "https://myinternal.domain.local" -tenantName "TurboTenant" -tags ("tag123","cooltenant") -objectData $ownAddition -LogToFile $false
    
    #>
    param(
        [parameter(mandatory)]
        $Url,
        [parameter(mandatory)]
        $tenantName,
        $objectData,
        [string[]]$tags,
        [parameter(mandatory)]
        [ValidateSet("True","False")]
        $LogToFile
    )
    if (Find-NetboxConnection){
        $tenantName = Remove-BadStringCharacters($tenantName)
        $tenantObject = @{
            name = $tenantName
            slug = Remove-SpecialCharacters($tenantName)
        }
        if ($objectData){
            $tenantObject += $objectData
        }
        if ($tags){
            $tagObject = @{
                tags = @()
            }
            foreach ($tag in $tags){
                $tagObject.tags += @{
                    name = "$tag"
                    slug = "$tag"
                }
            }
            $tenantObject += $tagObject
        }
        
        $tenantObject = $tenantObject | ConvertTo-Json -Compress
        
        Invoke-TryCatchLog -LogType CREATE -InfoLog "Creating new Netbox Tenant: $tenantName" -LogToFile $LogToFile -ScriptBlock {
            Invoke-RestMethod -Method POST -Uri "$Url/api/tenancy/tenants/" -Headers $netboxAuthenticationHeader -Body $tenantObject -ContentType "application/json"
        }
    }
}

function Remove-NetboxObject {
    <#
    .SYNOPSIS
    Remove any sort of Netbox Object by supplying its ID
    
    .DESCRIPTION
    Remove any sort of Netbox Object by supplying its ID, APIEndpoint need to be set like  this example: '/api/tenancy/tenants/'
    
    .PARAMETER Url
    Your Netbox URL
    
    .PARAMETER APIEndpoint
    The APIEndpoint for example: /api/tenancy/tenants/
    
    .PARAMETER ObjectID
    The ID of the object you want to delete/remove
    
    .PARAMETER LogToFile
    Connect to PSLoggingFunctions module, read more on GitHub, it create a Log folder in your directory if set to True
    
    .EXAMPLE
    Remove-NetboxObject -Url "https://netbox.internal.local" -APIEndpoint "/api/tenancy/tenants/" -ObjectID "235" -LogToFile $True
    
    .NOTES
    You need API permissions for the objects you want to delete.
    #>
    Param(
        [parameter(mandatory)]
        $Url,
        [parameter(mandatory)]
        $APIEndpoint,
        [parameter(mandatory)]
        $ObjectID,
        [parameter(mandatory)]
        [ValidateSet("True","False")]
        $LogToFile
    )
    if (Find-NetboxConnection){
        Invoke-TryCatchLog -LogType DELETE -InfoLog "Removing Netbox Object: $($APIEndpoint) - $($ObjectID)" -LogToFile $LogToFile -ScriptBlock {
            Invoke-RestMethod -Method DELETE -Uri "$($Url)$($APIEndpoint)$($ObjectID)/" -Headers $netboxAuthenticationHeader -Body $DeleteObject -ContentType "application/json"
        }
    }
}