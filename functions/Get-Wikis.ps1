function Get-Wikis {
    param (
        [string] $project = $null,
        [string] $organization = $null,
        [hashtable] $headers = $global:gHeaders,
        [string] $baseUrl = $global:strOrgUri,
        [string] $wikiName = "",
        [string] $apiVersion = "api-version=6.0"
    )
    $requestURL = ""
    If ( ($project.Length -GT 0 ) -and ($organization.Length -gt 0 ) -and ($wikiName.Length -gt 0 )) {
        #
        # Build the workitems request URL from the project, organization and the wiki ID or name
        #
        $requestURL = [string]::Format("{0}{1}/_apis/wiki/wikis/{2}", $baseUrl,  $project, $wikiName)
        $dbgStr = [string]::Format("Get-Wikis -> requestUrl: {0}", $requestURL)
        Write-DebugInfo -debugString DarkBlue $dbgStr
    }
    elseIf ( ($project.Length -GT 0 ) -and ($organization.Length -gt 0 ))
    {
        #
        # Build the base wiki URI to return all wikis
        #
        $requestURL = [string]::Format("{0}{1}/_apis/wiki/wikis", $baseUrl, $project)
        $dbgStr = [string]::Format("Get-Wikis -> requestUrl: {0}", $requestURL)
        Write-DebugInfo -debugString  $dbgStr -ForegroundColor DarkBlue
    }
    else {
        #
        # At this point, if the requestURL has a length greater than 0, then we can add the suffix values to complete the 
        # request.
        # Otherwise, we should throw and argument exception and exit the cmdlet.
        #
        $outError = [string]::Format("Get-Wikis: Unable to build request URL from input data: baseUrl: {0}, project: {1}, organization: {2}", $baseUrl, $project, $organization)
        Write-DebugInfo -ForegroundColor DarkBlue -debugString $outError
        throw $outError
    }
    $requestUrl = [string]::Format("{0}?{1}", $requestURL, $apiVersion)
    Write-DebugInfo -ForegroundColor DarkYellow $headers.Authorization
    write-DebugInfo -ForegroundColor DarkYellow $requestUrl
    $resheaders = $null
    $results = $null
    $results = Invoke-RestMethod -Uri $requestURL -Headers $headers -ResponseHeadersVariable resheaders
    $dbgStr  = [string]::Format("Get-Wikis -> Exit Function")
    Write-DebugInfo -ForegroundColor DarkYellow $dbgStr
    return $results
}