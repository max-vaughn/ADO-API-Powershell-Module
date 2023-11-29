
[[_TOC_]]


# **Introduction**

The purpose of this document is to provide information on how to add additional cmdlets to the project and have them load when the module is imported.

# **General Steps**
The general steps are as follows.  
1.  Create a cmdlet script file in the **.\functions** folder, using Get-WikiPage as an example of your cmdlet, create a file called **Remove-WikiPage.ps1** in the **.\functions** folder.  
1. Add the cmdlet to the **.\\_RootModuleShared.psm1** file using the same format as all the others.  using the **Remove-WikiPage.ps1** as an example, the you would add a the line:
```
Export-Module -Function Remove-WikiPage.ps1
```   
3. Add the cmdlet to the **.\\AdoApiSupport.psd1** in the **NestedModules** array, add the cmdlet name to the list.  Using the example of the **Remove-WikiPage** cmdlet add the following line somewhere in the array list  
```
".\functions\Remove-WikiPage.ps1",
```  
4. In the same file, **.\\AdoApiSupport.psd1**,  in the **FunctionsToExport** array, add the cmdlet name to the list.   Using the example of the **Remove-WikiPage** cmdlet add the following line somewhere in the array list  
```
"Remove-WikiPage",
```  
