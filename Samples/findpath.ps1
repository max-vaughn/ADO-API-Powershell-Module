param (
    [string] $pertok,
    [string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$retH = new-object psobject
$page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -basePath $PathVar -headers $Context.Headers -recursionLevel "none" -includeContent $false -returnHeaders $retH -returnPageobject $true

