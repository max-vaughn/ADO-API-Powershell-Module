param (
    [string] $pertok = "ExFHdQsR6LhpEYbSFybEp4p7EgJ3AHSXQrPVSUvIGKLNbCNaUb9bJQQJ99BAACAAAAAAArohAAASAZDOzZFh",
    [string] $InputFile = "D:\data\dp_process_list_with_YAML.csv",
    [bool] $debugcmd = $false
)
$articles = Import-CSV -Path $InputFile
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$output = @()
$total = $articles.Count
$counter = 0
$proxyTags = "cw.DP-Processes"
foreach ($item in $articles) {
    $outItem = $item.PSObject.Copy()
    if ( $item.YAMLTags.Length -gt 0) {    
    #if ( $proxyTags.Length -gt 0) {
        #
        # Tags are present, replace the current tags
        #
        $PageID = $item.pageID
        $NewTags = $item.YAMLTags.Split(';')

        #$NewTags = $proxyTags.Split(';')
        $retH = new-object PSObject
        $page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -pageId $PageID -headers $Context.Headers -recursionLevel "none" -includeContent $true -returnHeaders $retH
        if ( $null -eq $page ) {
            $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "Not Found"
        }
        else {
            $NewContent = ""
            $NewContent = Remove-YAMLTags -ContentIn $page.content -YAMLTags $NewTags -AddTags $true
            $outP = Update-WikiPage -adoContext $Context -pageID $PageID -Content $newContent -ETag $retH.returnHeaders.Etag[0]
            if ( $null -eq $outP ) {
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
    $counter++
    write-host -NoNewline "`r$counter of $total"
}
$output | export-csv -Path "D:\data\App_Proxy_list_updated.csv" -Force


