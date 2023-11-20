param (
    [string] $pertok,
    [string] $PageID = "1197510",
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$retH = new-object psobject
$page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -pageId $PageID -headers $Context.Headers -recursionLevel "none" -includeContent $true -returnHeaders $retH
$newContent = $page.content
$newContent = $newContent + "  **MAMA MIA**  *Too Cool*  "
$Global:debugCmdlets = $true
$global:pup =  Update-WikiPage -adoContext $Context -pageID 1197510 -Content $newContent -ETag $retH.returnHeaders.Etag[0]

