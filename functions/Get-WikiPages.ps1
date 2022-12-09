#
# Get-WikiPages
#
function Get-WikiPages {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]  $wikiUri,
        [string]  $wikiPageFullUrl = "",
        [hashtable] $headers,
        [string] $basePath,
        [ValidateSet( "none", "oneLevel", "full", "oneLevelPlusNestedEmptyFolders")]
        [string] $recursionLevel = "none",
        [string] $apiVersion = "api-version=6.0-preview.1",
        [bool]$includeContent = $false
    )
    if ( $wikiPageFullUrl.Length -gt 0 ) {
        $wikiPages = [string]::Format("{0}?recursionLevel={1}&includeContent={2}&{3}", $wikiPageFullUrl, $recursionLevel, $includeContent.ToString(), $apiVersion)
        $wikiPages = $wikiPageFullUrl
    }
    else {
        $wikiPages = [string]::Format("{0}/pages?path={1}&recursionLevel={2}&includeContent={3}&{4}", $wikiUri, $basePath, $recursionLevel, $includeContent.ToString(), $apiVersion)
        Write-DebugInfo -BackgroundColor DarkRed $wikiPages
    }
    $results = Invoke-RestMethod -Uri $wikiPages -Headers $headers
    return $results
}