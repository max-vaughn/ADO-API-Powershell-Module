param (
    [string] $pertok = "",
    [string] $InputFile = "C:\data\acct_updated.csv",
    [bool] $debugcmd = $false
)
$articles = Import-CSV -Path $InputFile
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$output = @()
foreach ($item in $articles) {
    $outItem = $item.PSObject.Copy()
    if ( $item.Tags.Length -gt 0) {
        #
        # Tags are present, replace the current tags
        #
        $PageID = $item.pageID
        $NewTags = $item.Tags.Split(';')
        $retH = new-object PSObject
        $page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -pageId $PageID -headers $Context.Headers -recursionLevel "none" -includeContent $true -returnHeaders $retH
        if ( $null -eq $page ) {
            $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "Not Found"
        }
        else {
            $NewContent = ""
            $NewContent = Remove-YAMLTags -ContentIn $page.content -YAMLTags $NewTags -AddTags $true
            $outP = Update-WikiPage -adoContext $Context -pageID $PageID -Content $newContent -ETag $retH.returnHeaders.Etag[0]
            if( $null -eq $outP ) {
                $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "Failed"
            }
            elseif ( $outP.id -eq $pageID ) {
                #
                # Successfully updated the wiki article with new tags.
                #
                $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "Updated"
            }
            else {
                # 
                # Failed to update the wiki article with new tags
                #
                $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "Failed"
            }
        }
    }
    else {
        #
        # Input data had no tags
        #
        $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "No Actions"
    }
    $output = $output + $outItem
}



