param (
    #[string] $pertok = "BL2uQ3qRD1prW8HBaMURftyBxiqHuCla5jtKENMw2EgLM81Ft6QfJQQJ99AKACAAAAAAArohAAASAZDO0XNu",
    [string] $pertok = "4CK4OWYRQcHcL3Wj8UpqjYoCxkvQ6BY6XXHFtxgYiuIsdA107gNYJQQJ99AKACAAAAAAArohAAASAZDO79S6",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'C:\temp\data\beckworkitems.csv',
    [string] $OutData = 'C:\temp\data\beckworkitemsout.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability"  -project "AzureAD"
$wikiUrl = $Context.WikiInfo[0].value.url
$page = Get-WikiPage -headers $Context.Headers -wikiUri $wikiUrl -pageId 567300 -returnPageObject $true
$TskObjs = Import-Csv -Path $InputData 
foreach( $tobj in $TskObjs){
    $page = Get-WikiPage -wikiPageFullUrl $tobj.URL -headers $Context.Headers -returnPageObject $true
    $wikiPage = Get-AdoWikiYAMLtags -Context $Context  -wikiPageFullUrl $tobj.URL -recursionLevel oneLevel
    $tobj | Add-Member -Name "YAMLTags" -Type NoteProperty -Value $wikiPage[0].YAMLTags
}
$TskObjs | Export-Csv -Path $OutData -Force 
