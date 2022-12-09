function Get-WikiPageIdFromTagPage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $wikiUri = "",
        [hashtable] $headers,
        [string] $projectId,
        [string] $apiVersion = "api-version=6.0",
        [PSCustomObject] $pageInfo = $null
    )
    #
    # Check to see if we have an object that represents a specific
    # wiki page.  If the object is not null, then we chack the url property
    # if the pageInfo.Content value, if the content is present, proceed with parsing, assuming 
    # that the content is in the form of a tag page in the CSS Wiki
    # 
    if ( $pageInfo -ne $null ) {
        if ( $pageInfo.content.Length -gt 0 ) {
            # 
            # the object has content.  Assume its an MD file in the form of
            # all other tag md files.  Find the  lines starting with " -"
            # and parse out the wiki file names
            #
            $strReader = new-object System.IO.StringReader -ArgumentList $pageInfo.Content
            $urlLines = @();
            do {
                $line = $strReader.ReadLine()
                if ( $line -ne $null ) {
                    if ( $line.Length -gt 4 ) {
                        if ( $line.IndexOf(" -", 0, 4) -eq 0 ) {
                            $urlLines += $line
                        }
                    
                    }
                }
                else {
                    break
                }

            } while ( $true )
            #
            # Check to see if there were any lines collected
            #
            $pagePaths = @()
            if ( $urlLines.Count -gt 0 ) {
                foreach ( $item in $urlLines ) {
                    #
                    # If the item lengt is greater than 3 continue to parse
                    # Replacing hex characters with appropriate values and 
                    # removing the - characters
                    #
                    if ( $item.Length -gt 3 ) {
                        #
                        # Find the first closing bracket so we can parse
                        # the relative link part of the MD link syntax line.
                        #
                        $closeBracket = $item.IndexOf("]", 0)
                        if ( $closeBracket -gt 0) {
                            $openPren = $item.IndexOf("(" , $closeBracket)
                            $closePren = $item.IndexOf(")", $openPren)
                            $pathValue = $item.Substring( $openPren + 1, ($closePren - $openPren - 1))
                            #
                            # Change - to space
                            #
                            $pathValue = $pathValue.Replace("-", " ")
                            #
                            # Change %2D to "-"
                            #
                            $pathValue = $pathValue.Replace("%2D", "-")
                            #
                            # Change &#40 to "("
                            #
                            $pathValue = $pathValue.Replace("&#40;", "(")
                            #
                            # Change &#41 to ")"
                            #
                            $pathValue = $pathValue.Replace("&#41;", ")")
                            $pagePaths += $pathValue
                            Write-DebugInfo -ForegroundColor DarkCyan "pathValue- $pathValue"
                        } # end of checking $closeBracket
                    } # end of checking to see if the item is the appropirate length
                } # End of foreach loop processing lines
            }# End of loop to check if we have data to parse
            # 
            # Check to see if we have URLs in the array.  If so, lets get thier page IDs
            #
            $pageIds = @()
            if ( $pageInfo.isParentPage -eq $true ) {
                $tmpPaths = @()
                foreach ( $item in $pagePaths) {
                    if ( $item.IndexOf('/', 0, 1) -eq -1 ){
                        $tmp = $item
                        if( $tmp.IndexOf(".md") -gt 0) {  
                            $tmp = $tmp.Substring(0, ($tmp.IndexOf(".md")))
                        }
                        $tmp = [string]::Format("{0}{1}", $pageInfo.path, $tmp.SubString($tmp.IndexOf("/")))
                        $tmpPaths += $tmp
                    }
                    else {
                        $tmpPaths += $item
                    }
                }
                $pagePaths = $tmpPaths
            }
            
            if ( $pagePaths.Count -gt 0 ) {
                foreach ( $path in $pagePaths ) {
                    write-Host -ForegroundColor DarkYellow "path - $path"
                    $wikiPage = Get-WikiPage -wikiUri $wikiUri  -headers $headers -includeContent $false -basePath $path
                    if ( $wikiPage.id -gt 0 ) {
                        $wikiId = $wikiPage.Id
                        Write-DebugInfo -ForegroundColor DarkYellow "PageId: $wikiId"
                        $pageUri = [string]::Format("{0}?pageID={1}", $wikiUri, $wikiPage.id)
                        $pageUri = $pageUri.Replace("/_apis/wiki", "/_wiki")
                        Write-DebugInfo -ForegroundColor DarkGreen "pageUri $pageUri"
                        $pageStats = Get-WikiPageStats -wikiUri $wikiUri -headers $headers -numberDaysFromToday 30 -returnTotalCountOnly $true -pageId $wikiId
                        $pageInfo = New-Object -TypeName PSObject
                        $pageInfo | Add-Member -Name "pageId" -Type NoteProperty -Value $wikiPage.id
                        $pageInfo | Add-Member -Name "pagePath" -Type NoteProperty -Value $path
                        $pageInfo | Add-Member -Name "pageUri" -Type NoteProperty -Value $pageUri
                        $pageInfo | Add-Member -Name "Hits last 30 days" -Type NoteProperty -Value $pageStats
                        $pageInfo | Add-Member -Name "getItemPath" -Type NoteProperty -Value $wikiPage.gitItemPath
                        $pageIds += $pageInfo

                    }
                }
                return $pageIds
            }

        }

    }

}