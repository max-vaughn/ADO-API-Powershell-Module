param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'D:\data\Master_20_30_percent_tagged_items_with_Comm.csv',
    [string] $OutData = 'D:\data\20_30_percent_task_import.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$TskObjs = Import-Csv -Path $InputData 
$outItems = @()# Define the CSV content
foreach( $tobj in $TskObjs ){
    $outItem = new-object psobject
    if(  $tobj.'Assigned To'.Length -gt 0 ) {
        $outItem | Add-Member -Name "State" -Type NoteProperty -Value $tobj.State
        $outItem | Add-Member -Name "ID" -Type NoteProperty -Value $tobj.ID
        $outItem | Add-Member -Name "Work Item Type" -Type NoteProperty -Value $tobj.'Work Item Type'
        $outItem | Add-Member -Name "Title" -Type NoteProperty -Value $tobj.Title
        $outItem | Add-Member -Name 'Assigned To' -Type NoteProperty -Value $tobj.'Assigned To'
        if( $tobj.CommTag.Length -gt 0 ) {
            $tags = $tobj.Tags + ";" + $tobj.CommTag
        }
        else {
            $tags = $tobj.Tags
        }
        $outItem | Add-Member -Name "Tags" -Type NoteProperty -Value $tags
        $outItems = $outItems + $outItem
    }
}
$outItems | Export-Csv -Path $OutData -Force 