Function Connect-NetboxAPI {
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
    New-NetboxTenant -Url "https://myinternal.domain.local" -tenantName "TurboTenant" -tags ("tag123","cooltenant") -objectData @{custom_fields=@{customer_id = "123123"}} -LogToFile $false
    
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