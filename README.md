# ADO-API-Powershell-Module
Powershell wrapper for some of the Microsoft Azure DevOps APIs documented at the following link:  
[Microsoft ADO Rest API Documentation](https://learn.microsoft.com/en-us/rest/api/azure/devops/graph/?view=azure-devops-rest-6.0)

# Acknowlegments
Many thanks to Will Fiddes of Microsoft Azure Directory Developer Support for his assistance in the initial structure of this module.  This module uses the project:  
[Azure-AD-Support-Module GitHub project](https://github.com/ms-willfid/Azure-AD-Support-PowerShell-Module)  
This project adopts the same structure but is tailored to the Azure DevOps APIs.

# Current Status of this project
At the moment, the only thing that will work is importing the psm1 file.  The other items in this project have not been fully attached.  This status will be updated with versioning information once items are tested.  
To create a single PSM1 file from the script files, please review:  
[AllInOnePSM1\\Readme.md](https://github.com/max-vaughn/ADO-API-Powershell-Module/blob/main/AllInOnePSM1/Readme.md)

# Installation instructions  
From the repo install directory, the **.\AdoApiSupport.psd1** manifest file contains all the information needed to install the cmdlets.

If you are using  Visual Studio Code with the powershell extension, the PSH extension starts in the root directory of the Githup repository.  Simply use the following command line:  
```Powershell
Import-Module -Name .\AdoApiSupport.psd1
```

If you are debugging or adding functions and you want the current versions of the files to be loaded use this command line:  
```Powershell
Import-Module -Name .\AdoApiSupport.psd1 -Force
```
# Disclaimer

Use this PowerShell module at your own risk. There is no support model for this PowerShell module except through this github repository. Please report any issues here... 
https://github.com/max-vaughn/ADO-API-Powershell-Module/issues

This PowerShell module is intended to help illustrate simple REST concepts using the Azure Dev Ops REST APIs.  Do not assume that the examples of calling APIs in these cmdlets is the recommended method for using these APIs.  This is just one person's interpretation of how the APIs work together and can be used to accomplish a specific tasks.

DO NOT USE this PowerShell module for production and do not have any dependency on any of the cmdlets. Expect breaking changes and no SLA on resolving issues within this PowerShell module.

Cmdlets may change at any time without notice.

Best regards,  
Max Vaughn
