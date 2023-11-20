param (
    [string] $pertok,
    [string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management",
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$retH = new-object psobject
$page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -basePath $PathVar -headers $Context.Headers -recursionLevel "none" -includeContent $false -returnHeaders $retH

