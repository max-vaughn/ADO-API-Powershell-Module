#
# Get-WikiPageStats 
#   $wikiUri - this value is retrieve by using the Get-Wikis cmdlet for a specific wiki item
#       within a project.  The information comes back as described at this link:
#       https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/wikis/get?view=azure-devops-rest-6.0
#       using the url property, this gives you the base location of the wiki.
#
#    $headers - this hashtable contacts the header values for the request.
# 
#    $pageId - this is the pageId that you want stats for, this value is appended to the wikiUri along with the page collection
#
#    $numberDaysFromToday - self explanatory, this value is added as the pageViewsForDays parameter in the URL.
#
#  The object returned contains the results of the REST request.  An additional property, totalCount is 
#  calculated from the returned results and added as a property to the results object and returned to the caller.
#
#    
function Get-WikiPageStats { 
    param (
        [Parameter()]
        [string] $wikiUri,
        [hashtable] $headers,
        [string] $pageId,
        [string] $numberDaysFromToday = "7",
        [string] $apiVersion = "api-version=6.0-preview.1",
        [bool] $returnTotalCountOnly = $false
    )
    $pageUri = [string]::Format("{0}/pages/{1}/stats?pageViewsForDays={2}&{3}", $wikiUri, $pageId, $numberDaysFromToday, $apiVersion)
    Write-DebugInfo -ForegroundColor Blue $pageUri
    $results = Invoke-RestMethod -Uri $pageUri -Headers $headers
    if( $global:debugCmdlets -eq $true){
        $outStr = "Get-WikiPageStats Object '$results -> "
        Write-DebugObject -inputObject $results -ForegroundColor Blue $outStr
    }
    $totalHits = 0
    foreach ( $stat in $results.viewStats ) { $totalHits = $stat.count + $totalHits }
    Write-DebugInfo -ForegroundColor DarkRed $totalHits
    $results | Add-Member -Name "totalCount" -Type NoteProperty -Value $totalHits
    if ( $returnTotalCountOnly ) { $results = $totalHits }
    return $results
}