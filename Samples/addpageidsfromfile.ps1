param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = "D:\data\dvidripped.txt",
    [string] $OutData = 'D:\data\dvidripped_pagiIDs.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$items = Import-CSV -Path $InputData
$outItems = @()
foreach( $item in $items){
    $outItem = $Item.PSObject.Copy()
    $linkParts = $item.wikiPageFullUrl.Split("/")
    $pagIdIndex = $linkParts.Count - 2
    $outItem | Add-Member -Name "PageID" -Type NoteProperty -Value $linkParts[$pagIdIndex]
    $outItems = $outItems + $outItem
}
$outItems | Export-Csv -Path $OutData -Force 
