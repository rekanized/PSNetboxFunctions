Powershell API functions for Netbox
<br><br>
This repository will keep updating as the functions I use internally at work start growing.<br>
<br>
At this moment it is mostly used for Synchronization activities to retrieve data and put it somewhere else, but when we start making changes to objects this will be further updated.

# Required modules
* PSLoggingFunctions (https://github.com/rakelord/PSLoggingFunctions)

# Getting started
## Download this PowerShell Module and all Required PowerShell Modules and place them in your PSModulePath folder<br>
You can use this command to show your available locations
```powershell 
$env:PSModulePath -split ";"
``` 

# Functions examples
## Connect to the API
First you are going to have to create a API Token which is explained in Netbox official API documentation.
<br><br>
- -LogToFile parameter is connected to the PSLoggingFunctions module and is used for easy logging.

```powershell
Connect-NetboxAPI -Url "<YOUR NETBOX URL>" -Token "<API TOKEN>" -LogToFile "<True/False>"
```
You will retrieve a global variable in your script called '$netboxAuthenticationHeader' the variable can be used with your own Invoke-RestMethod commands if needed, otherwise you can use the module functions which have this variable implemented already.

## Retrieve Netbox Objects
The parameter APIEndpoint is based on the Netbox documentation, so for example if you want to retrieve all devices from dcim you set it to '/api/dcim/devices/' if you want to get tenants you type '/api/tenancy/tenants/'
```powershell
Get-NetboxObjects -Url "<YOUR NETBOX URL>" -APIEndpoint "<API ENDPOINT>" -LogToFile "<True/False>"
```