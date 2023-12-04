#
# Get-GitItems
# Not finished needs more work, still creating URI call
# 10/25/2020
<#/ function Get-GitItems {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $orgUri,
        [string] $projectId,
        [string] $repositoryId,
        [ValidateSet( "none", "oneLevel", "full", "oneLevelPlusNestedEmptyFolders")]
        [string] $recursionLevel = "none",
        [string] $scopePath = "",
        [string] $itemPath = "",
        [bool] $latestProcessedChange = $true
        [string] $apiVersion = "api-version=6.0"
    )
    $resourceUri = ""
    if( $scopePath.Length -eq 0 and $itemPath.Length -eq 0) {
        $resourceUri = [string]::Format({0}/{1}/_apis/git/repositories/{3}/items?)
    }
    elseIf ( $itemPath.Length -gt 0 )
    {
        $resourceUri = [string]::Format({0}/{1}/_apis/git/repositories/{3}/items?path={4}
    }
    
}
#>