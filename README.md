Powershell API functions for Netbox
<br><br>
This repository will keep updating as the functions I use internally at work start growing.<br>
<br>
At this moment it is mostly used for Synchronization activities to retrieve data and put it somewhere else, but when we start making changes to objects this will be further updated.

# Installation
```powershell 
Install-Module -Name PSNetboxFunctions
```
This will also install Dependency
* PSLoggingFunctions (https://github.com/rakelord/PSLoggingFunctions)

# Offline Installation
Just run the OfflineInstallation.ps1<br>
PS: You need to download all the files into the same directory and then run the script, they will then be copied to the Users PSModuleDirectory.


# Functions examples
## Connect to the API
First you are going to have to create a API Token which is explained in Netbox official API documentation.
<br><br>
- -LogToFile parameter is connected to the PSLoggingFunctions module and is used for easy logging.

```powershell
Connect-NetboxAPI -Url "<YOUR NETBOX URL>" -Token "<API TOKEN>" -LogToFile "<True/False>"
```
You will retrieve a global variable in your script called '$netboxAuthenticationHeader' the variable can be used with your own Invoke-RestMethod commands if needed, otherwise you can use the module functions which have this variable implemented already.

## Retrieve Any Netbox Objects
The parameter APIEndpoint is based on the Netbox documentation, so for example if you want to retrieve all devices from dcim you set it to '/api/dcim/devices/' if you want to get tenants you type '/api/tenancy/tenants/'<br>
API Permissions need to be set for the objects you want to retrieve!
```powershell
Get-NetboxObjects -APIEndpoint "<API ENDPOINT>" -LogToFile "<True/False>"
```

## Delete Any Netbox Object
API Permissions need to be set for the objects you want to delete!
```powershell
#Example deleting a Tenant with ID 235
Remove-NetboxObject -APIEndpoint "/api/tenancy/tenants/" -ObjectID "235" -LogToFile $True
```

## New-NetboxTenant
```powershell
# If you want to add something to the customer value that does not already exist, for example a customer id.
$customAddition = @{
    custom_fields = @{
        customer_id = "123123"
    }
}

New-NetboxTenant -tenantName "TurboTenant" -tags ("tag123","cooltenant") -objectData $ownAddition -LogToFile $false

#if you have nothing extra to add just skip objectData and if there are no tags, you can skip that aswell.
New-NetboxTenant -tenantName "TurboTenant" -LogToFile $false
```

## New-NetboxSite
```powershell
# If you want to add a value to the site that does not already exist, for example a customer id.
$customAddition = @{
    custom_fields = @{
        customer_id = "123123"
    }
}

New-NetboxSite -siteName "My-road 12B" -tags ("tag123","coolsite") -objectData $customAddition -LogToFile $false

# if you have nothing extra to add just skip objectData and if there are no tags, you can skip that aswell.
New-NetboxSite -siteName "My-road 12B" -LogToFile $false
```