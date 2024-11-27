param (
    [string] $pertok = "5jBL9andFakkXeVmjbSCO6T0PDKnVa8mozfVi8gm2suoR05GGao7JQQJ99AKACAAAAAAArohAAASAZDO2Qte",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'C:\temp\data\beckworkitemsout.csv',
    [string] $OutData = 'C:\temp\data\beckworkitemsouttask.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "IdentityCommunities"  -project "Community - Identity Developer Experiences"
$item = Get-WorkItemById -orgUrl $Context.OrgUrl -project "Community - Identity Developer Experiences" -workItemID 6844  -header $Context.Headers
$item
#$retItem = Update-ADOWorkItem -orgUrl $Context.OrgUrl -project "Community - Identity Azure Dev Ops Wiki" -workItemID $taskId -operations $operations -header $Context.Headers
<#
foreach( $tobj in $TskObjs){
    $page = Get-WikiPage -wikiPageFullUrl $tobj.URL -headers $Context.Headers -returnPageObject $true
    $wikiPage = Get-AdoWikiYAMLtags -Context $Context  -wikiPageFullUrl $tobj.URL -recursionLevel oneLevel
    $tobj | Add-Member -Name "YAMLTags" -Type NoteProperty -Value $wikiPage[0].YAMLTags
}

$TskObjs | Export-Csv -Path $OutData -Force 
#>