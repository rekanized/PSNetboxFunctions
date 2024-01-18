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

    $testConnection = Invoke-RestMethod -Method GET -Uri "$Url/api/dcim/sites/" -Headers $netboxAuthenticationHeader
    $global:NetboxAuthenticated = $false
    if ($testConnection){
        $global:NetboxAuthenticated = $true
        Write-Log -Message "Netbox Authenticated: $NetboxAuthenticated" -Active $LogToFile
        Write-Host "Netbox Authenticated: $NetboxAuthenticated`nUse Header Connection Variable = "+'$netboxAuthenticationHeader'
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