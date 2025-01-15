param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'D:\data\20_30_percent_tagged_items_with_YAML.csv',
    [string] $OutData = 'D:\data\20_30_percent_tagged_items_with_Comm.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$TskObjs = Import-Csv -Path $InputData 
$outItems = @()
foreach ( $tobj in $TskObjs) {
    $outObj = $tobj.PSObject.Copy()
    $commTag = ""
    if ( $tobj.YAMLTags.Length -gt 0 ) {
        $tags = $tobj.YAMLTags.Split(';')
        foreach ( $tag in $tags ) {
            $idxTagStart = $tag.IndexOf("cw.comm-", 0, $tag.Length - 1 )
            if ( $idxTagStart -gt -1 ) {
                $commTag = $tag
            }
        }
    }
    $outObj | Add-Member -Name "CommTag" -Type NoteProperty -Value $commTag
    $outItems = $outItems + $outObj
}
$outItems | Export-Csv -Path $OutData -Force 
