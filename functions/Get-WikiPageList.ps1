<#
Get-WikiPageList
    This function will call the Get-WikiFoldersDocs and return a hash table of 
    WikiPage items 
    https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get?view=azure-devops-rest-5.0#wikipage

#>
Function Get-WikiPageList {
    param (
        [Parameter()]
        [string]  $wikiUri,
        [string]  $wikiPageFullUrl = "",
        [string]  $pageId = "",
        [ValidateNotNull()]
        [hashtable] $headers,
        [string] $basePath = "",
        [ValidateSet( "oneLevel", "full")]
        [string] $recursionLevel = "full",
        [string] $apiVersion = "api-version=7.1",
        [bool]$includeContent = $false
         )
    $articleList = Get-WikiFolderDocs -wikiUri $wikiUri -wikiPageFullUrl $wikiPageFullUrl -pageId $pageId -headers $headers -basePath $basePath -recursionLevel $recursionLevel -apiVersion $apiVersion -includeContent $includeContent
    Write-DebugInfo -ForegroundColor DarkCyan "Get-WikiPageList -> + "$articleList.Count
    $wikiPageList = @()
    foreach ($item in $articleList) {
        $resItem = Get-WikiPage -wikiPageFullUrl $item -headers $headers
        #
        # Build PageId reference URL and add it to the output
        #
        $pageUrl = $resItem.remoteUrl
        $lastSlash = $pageUrl.LastIndexOf("/")
        $pageUrl = $pageUrl.SubString(0, $lastSlash)
        $pageUrl = [string]::Format("{0}?pageID={1}", $pageUrl, $resItem.id)
        #
        # Create the return item object
        #
        $retItem = new-object PSObject
        $retItem | Add-Member -Name "pageID" -Type NoteProperty -Value $resItem.id
        $retItem | Add-Member -Name "pageUrl" -Type NoteProperty -Value $pageUrl
        $retItem | Add-Member -Name "path" -Type NoteProperty -Value $resItem.path
        $retItem | Add-Member -Name "url" -Type NoteProperty -Value $resItem.url
        $retItem | Add-Member -Name "gitItemPath" -Type NoteProperty -Value $resItem.gitItemPath
        $retItem | Add-Member -Name "Reviewer" -Type NoteProperty -Value ""
        $retItem | Add-Member -Name "Review Date" -Type NoteProperty -Value ""
        #
        # Stuff it into the list
        #
        $wikiPageList = $wikiPageList + $retItem 
    }
    return $wikiPageList
}