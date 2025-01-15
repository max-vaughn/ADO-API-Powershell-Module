param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'D:\data\20_30_percent_tagged_items.csv',
    [string] $OutData = 'D:\data\20_30_percent_tagged_items_pageIDs.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$items = Import-CSV -Path $InputData
$outItems = @()
foreach( $item in $items){
    $outItem = $Item.PSObject.Copy()
    $linkParts = $item.URL.Split("=")
    if( $linkParts.Count -eq 2 ){
    $outItem | Add-Member -Name "PageID" -Type NoteProperty -Value $linkParts[1]
    } else {
        $outItem  | Add-Member -Name "PageID" -Type NoteProperty -Value ""
    }
    $outItems = $outItems + $outItem
}
$outItems | Export-Csv -Path $OutData -Force 
