param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'C:\data\beckworkitems.csv',
    [string] $OutData = 'C:\data\beckworkitems_plus_M365_Identity.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability"  -project "AzureAD"
$wikiUrl = $Context.WikiInfo[0].value.url
#$page = Get-WikiPage -headers $Context.Headers -wikiUri $wikiUrl -pageId 567300 -returnPageObject $true
$TskObjs = Import-Csv -Path $InputData 
$total = $TskObjs.Count
$counter = 0
foreach ( $tobj in $TskObjs) {
    #$page = Get-WikiPage -wikiUri $wikiUrl -pageId $tobj.pageID -headers $Context.Headers -returnPageObject $true
    $page = Get-WikiPage -wikiPageFullUrl $tobj.URL  -headers $Context.Headers -returnPageObject $true
    if ( $null -eq $page ) {
        $tobj | Add-Member -Name "YAMLTags" -Type NoteProperty -Value ""
        $tobj | Add-Member -Name "WikiTitle" -Type NoteProperty -Value ""
        $tobj | Add-Member -Name "GitItemPath" -Type NoteProperty -Value ""
    }
    else {
        $wikiPage = Get-AdoWikiYAMLtags -Context $Context  -pageId $page.pageID -recursionLevel oneLevel
        $tobj | Add-Member -Name "YAMLTags" -Type NoteProperty -Value $wikiPage[0].YAMLTags
        $title = Split-Path -Path $wikiPage[0].path -Leaf
        $tobj | Add-Member -Name "WikiTitle" -Type NoteProperty -Value $title
        $tobj | Add-Member -Name "GitItemPath" -Type NoteProperty -Value $wikiPage[0].gitItemPath
    }
    $counter++
    write-host -NoNewline "`r$counter of $total"
}
$TskObjs | Export-Csv -Path $OutData -Force 
