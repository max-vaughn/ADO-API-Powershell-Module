param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    #[string] $InputFile = 'D:\data\dvidripped.txt',
    [string] $InputFile = "D:\data\dvidripped_pagiIDs.csv",
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$MSOLTemplateTxt = ("::: template /.templates/Shared/msol_azuread_deprication_warning.md`n",
                    ":::`n")
$articles = Import-CSV -Path $InputFile
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$wikiUrl = $Context.WikiInfo[0].value.url
$output = @()
$total = $articles.Count
$counter = 0
foreach ($item in $articles) {
    $retH = new-object PSObject
    $outItem = $item.PSObject.Copy()
    $page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -pageId $item.PageID -headers $Context.Headers -recursionLevel "none" -includeContent $true -returnHeaders $retH
    if ( $null -eq $page ) {
        $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "Not Found"
    }
    else {
        $endOfStream = $false
        $YAMLBlock = $false
        $addTemplate = $true
        $content = $page.content
        $srl = new-object System.IO.StringReader( $content ) 
        $NewContent = ""
        while ( -Not $endOfStream ) {
            $sline = $srl.ReadLine()
            if ( $null -eq $sline ) { break }
            $NewContent = $NewContent + $sline + "`n"
            if ( $sline.IndexOf("---", 0) -gt -1 ) {
                #
                # Start block fo YAML tags
                # Find the ending "---" and return all that is inbetween
                #
                while ($true) {
                    $srLine = $srl.ReadLine()
                    $NewContent = $NewContent + $srLine + "`n"
                    if ( $null -eq $srLine ) { 
                        $endOfStream = $true
                        break 
                    }
                    if ( $srLine.IndexOf("---") -gt -1 ) { 
                        $YAMLBlock = $true
                        break 
                    }
                }  

            }
            if ( $addTemplate ) {
                $NewContent = $NewContent + $MSOLTemplateTxt[0]
                $NewContent = $NewContent + $MSOLTemplateTxt[1]
                $addTemplate = $false
            }

        }
        $outP = Update-WikiPage -adoContext $Context -pageID $item.PageID -Content $newContent -ETag $retH.returnHeaders.Etag[0]
        #$outP = Update-WikiPage -adoContext $Context -wikiPageFullUrl $item.wikiPageFullUrl -Content $NewContent -ETag $retH.returnHeaders.Etag[0]
        if ( $null -eq $outP ) {
            $outItem | Add-Member -Name "Status" -Type NoteProperty -Value "Failed"
        }
        elseif ( $outP.id -eq $item.PageID ) {
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

    $output = $output + $outItem
    $counter++
    write-host -NoNewline "`r$counter of $total"
}
$output | export-csv -Path "D:\data\updated_MSOL_Deprecation_Info.csv" -Force
