param (
    [string] $pertok = "",
    [string] $PageID = "6785339",
    [bool] $debugcmd = $false
)
$NewTags = @("cw.New One","cw.New Two")
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$retH = new-object psobject
$page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -pageId $PageID -headers $Context.Headers -recursionLevel "none" -includeContent $true -returnHeaders $retH
$NewContent = ""
$NewContent = Remove-YAMLTags -ContentIn $page.content -YAMLTags $NewTags -AddTags $true
$outP =  Update-WikiPage -adoContext $Context -pageID $PageID -Content $newContent -ETag $retH.returnHeaders.Etag[0]

