param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'C:\temp\data\beckworkitemsout.csv',
    [string] $OutData = 'C:\temp\data\beckworkitemsouttask.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "CSSSI"  -project "CSS Knowledge Management"
$TskObjs = Import-Csv -Path $InputData 
#$taskId = 42607
#$item = $TskObjs[2]
#$taglist = $tagstr.SPlit(';')
$count = 0
foreach ( $item in $TskObjs ) {
    $operations = @()
    $tagList = ""
    if( $item.YAMLTags.Length -GT 0 ) {
            $taglist = $item.YAMLTags.Split(';')
    } else {
        $tagList = "No YAML Tags"
    }
    foreach ( $tg in $tagList) {
        $op = New-ADOCreateOperation -operation add -value $tg -path '/fields/System.Tags'
        $taskId = $item.ID
        $retItem = Update-ADOWorkItem -orgUrl $Context.OrgUrl -project "CSS Knowledge Management" -workItemID $taskId -operations $op -header $Context.Headers
    }
    Write-Host -NoNewline "`r$count -> $taskID"
    $count++
}
#$retItem = Update-ADOWorkItem -orgUrl $Context.OrgUrl -project "Community - Identity Azure Dev Ops Wiki" -workItemID $taskId -operations $operations -header $Context.Headers
<#
foreach( $tobj in $TskObjs){
    $page = Get-WikiPage -wikiPageFullUrl $tobj.URL -headers $Context.Headers -returnPageObject $true
    $wikiPage = Get-AdoWikiYAMLtags -Context $Context  -wikiPageFullUrl $tobj.URL -recursionLevel oneLevel
    $tobj | Add-Member -Name "YAMLTags" -Type NoteProperty -Value $wikiPage[0].YAMLTags
}

$TskObjs | Export-Csv -Path $OutData -Force 
#>