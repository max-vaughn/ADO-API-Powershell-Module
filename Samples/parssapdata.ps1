param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData ="D:\data\PCYMap.csv" ,
    [string] $OutData = 'D:\data\DevSAPKeys.txt',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$TskObjs = Import-Csv -Path $InputData 
$outItems = @()
$outstr = '('
foreach ( $tobj in $TskObjs) {
    $outstr = $outstr + $tobj.SAPKey + ","
}
$outstr = $outstr + ")"
Set-Content -Path $OutData -Value $outstr -Force