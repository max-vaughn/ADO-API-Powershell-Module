function Get-WikiPage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSobject] $returnHeaders = $null,
        [string]  $wikiUri,
        [string]  $wikiPageFullUrl = "",
        [string]  $pageId = "",
        [ValidateNotNull()]
        [hashtable] $headers = $global:gHeaders,
        [string] $basePath = "",
        [ValidateSet( "none", "oneLevel", "full", "oneLevelPlusNestedEmptyFolders")]
        [string] $recursionLevel = "none",
        [string] $apiVersion = "api-version=7.1",
        [bool]$includeContent = $false,
        [bool]$returnPageObject = $false
    )
    if ( $pageId.Length -gt 0 ) { 
        #
        # have a pageID, do pageID URL addressing
        #
        $wikiPage = [string]::Format("{0}/pages/{1}?recursionLevel={2}&includeContent={3}&{4}", $wikiUri, $pageId, $recursionLevel, $includeContent.ToString(), $apiVersion)
    }
    elseif ($wikiPageFullUrl.Length -gt 0 ) { 
        Write-DebugInfo -ForegroundColor DarkCyan $wikiPageFullUrl
        #
        # full page url like
        #  https://supportability.visualstudio.com/f3a37cb5-3492-4581-8dbd-f3381f2b1736/_apis/wiki/wikis/cdffcfd7-d961-4bdd-b53b-2759c05108d2/pages/%2FGeneralPages%2FAzure
        #
        if( $wikiPageFullUrl.IndexOf("?") -gt 0 ){
            #
            # Check to see if this is a call from Get-WikiPageList, it will have a ?Path parameter 
            # so we want to use &'s to connect the parameters
            #
            $wikiPage = [string]::Format("{0}&recursionLevel={1}&includeContent={2}&{3}", $wikiPageFullUrl, $recursionLevel, $includeContent.ToString(), $apiVersion)
        }
        else {
            #
            # Normal full wiki url that needs all of the parameters added
            #
            $wikiPage = [string]::Format("{0}?recursionLevel={1}&includeContent={2}&{3}", $wikiPageFullUrl, $recursionLevel, $includeContent.ToString(), $apiVersion)
        }
        
    }
    elseIf ( $basePath.Length -gt 0 ) {
        #
        # No pageID or full page url, however, we have a base bath for the pages, 
        # Retrieve pages based on the path 
        #
        $wikiPage = [string]::Format("{0}/pages?path={1}&recursionLevel={2}&includeContent={3}&&{4}", $wikiUri, $basePath, $recursionLevel, $includeContent.ToString(), $apiVersion)
    }
    #
    # Debug information
    #
    $dbgString = [string]::Format("Get-WikiPage -> {0}", $wikiPage)
    Write-DebugInfo -ForegroundColor DarkCyan $dbgString
    $results = Invoke-RestMethod -Uri $wikiPage -Headers $headers -ResponseHeadersVariable retH
    if( $null -eq $returnHeaders ){
        $returnHeaders = new-object psobject
    }
    $returnHeaders | add-member NoteProperty returnHeaders $retH
    $outStr = write-output $results
    $dbgString = [string]::Format("Get-WikiPage -> Results:{0}", $outStr)
    Write-DebugInfo $dbgString -ForegroundColor DarkCyan
    if( $returnPageObject -eq $true ){
                #
        # Build PageId reference URL and add it to the output
        #
        $pageUrl = $results.remoteUrl
        $lastSlash = $pageUrl.LastIndexOf("/")
        $pageUrl = $pageUrl.SubString(0, $lastSlash)
        $pageUrl = [string]::Format("{0}?pageID={1}", $pageUrl, $results.id)
        #
        # Create the return item object
        #
        $retItem = new-object PSObject
        $retItem | Add-Member -Name "pageID" -Type NoteProperty -Value $results.id
        $retItem | Add-Member -Name "pageUrl" -Type NoteProperty -Value $pageUrl
        $retItem | Add-Member -Name "path" -Type NoteProperty -Value $results.path
        $retItem | Add-Member -Name "url" -Type NoteProperty -Value $results.url
        $retItem | Add-Member -Name "gitItemPath" -Type NoteProperty -Value $results.gitItemPath
        $retItem | Add-Member -Name "remoteUrl" -Type NoteProperty -Value $result.remoteUrl
        $retItem | Add-Member -Name "Reviewer" -Type NoteProperty -Value ""
        $retItem | Add-Member -Name "Review Date" -Type NoteProperty -Value ""
        $results = $retItem
    }
    return $results
}