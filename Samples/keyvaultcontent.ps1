param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    #[string] $PathVar = "Authentication",
    [string] $PathVar = "Azure%20Key%20Vault%20Overview",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "ASIM-Security" -project "Information Protection"
$wikiInfo = Get-WikiFromContext -context $Context -Name "Key Vault"
$pageList = Get-WikiPageList -WikiUri $wikiInfo.url -basePath $PathVar -headers $Context.Headers -recursionLevel full
$pageList.Count
$pageList | export-csv -NoTypeInformation -Path .\KeyVaultList.csv -Force
