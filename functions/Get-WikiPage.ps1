function Get-WikiPage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSobject] $retHeaders,
        [string]  $wikiUri,
        [string]  $wikiPageFullUrl = "",
        [string]  $pageId = "",
        [ValidateNotNull()]
        [hashtable] $headers = $global:gHeaders,
        [string] $basePath = "",
        [ValidateSet( "none", "oneLevel", "full", "oneLevelPlusNestedEmptyFolders")]
        [string] $recursionLevel = "none",
        [string] $apiVersion = "api-version=6.0-preview.1",
        [bool]$includeContent = $false
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
        $wikiPage = [string]::Format("{0}?recursionLevel={1}&includeContent={2}&{3}", $wikiPageFullUrl, $recursionLevel, $includeContent.ToString(), $apiVersion)
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
    $retHeaders | add-member NoteProperty returnHeaders $retH
    $outStr = write-output $results
    $dbgString = [string]::Format("Get-WikiPage -> Results:{0}", $outStr)
    Write-DebugInfo $dbgString -ForegroundColor DarkCyan
    return $results
}