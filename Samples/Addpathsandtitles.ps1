param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'D:\data\20_30_percent_tagged_items_pageIDs.csv',
    [string] $OutData = 'D:\data\20_30_percent_tagged_items_pageIDs_paths.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability"  -project "AzureAD"
$TskObjs = Import-Csv -Path $InputData 
$total = $TskObjs.Count
$counter = 0
foreach ( $tobj in $TskObjs) {
    $page = Get-WikiPage -wikiUri $Context.WikiInfo.Value[0].url -pageId $tobj.PageID -headers $Context.Headers -returnPageObject $true
    if ( $null -eq $page ) {
        $tobj | Add-Member -Name "WikiTitle" -Type NoteProperty -Value ""
        $tobj | Add-Member -Name "GitItemPath" -Type NoteProperty -Value ""
    }
    else {
        $title = Split-Path -Path $page.path -Leaf
        $tobj | Add-Member -Name "WikiTitle" -Type NoteProperty -Value $title
        $tobj | Add-Member -Name "GitItemPath" -Type NoteProperty -Value $page.gitItemPath
    }
    $counter++
    write-host -NoNewline "`r$counter of $total"
}
$TskObjs | Export-Csv -Path $OutData -Force