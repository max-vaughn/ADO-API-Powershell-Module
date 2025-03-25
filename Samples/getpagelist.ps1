param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    #[string] $PathVar = "Authentication",
    [string] $PathVar = "/",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$wikiInfo = Get-WikiFromContext -context $Context -Name "AzureAD"
$pageList = Get-WikiPageList -WikiUri $wikiInfo.url -basePath $PathVar -headers $Context.Headers -recursionLevel full
$pageList.Count
$pageList | export-csv -NoTypeInformation -Path 'd:\data\all_articles_2_4_25.csv' -Force