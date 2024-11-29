function New-ADOWorkItemComment {
    param(
        [Parameter()]
        [PSObject] $Context = $null,
        [string]  $workItemsUrl = "",
        [string] $baseUrl = $global:strOrgUri,
        [string] $project = "",
        [string] $orgUrl = "",
        [string] $workItemID = $null,
        [string] $workItemType = "comments",
        [string] $CommentText = $null,
        [hashtable] $headers = $null,
        [ValidateSet( "None", "Relations", "Fields", "Links", "All")]
        [string] $expand = "None",
        [string] $apiVersion = "api-version=6.0-preview.3"
    )
    $witSuffix = "/_apis/wit/workitems/"
    $requestURL = ""
    if( $null -eq $Context) {

    } else {
        $headers = $Context.Headers.Clone()
    }
    if( $null -eq $headers ){
        $outError = "`$headers parameter is null and `$Context is not present.  Provide either `$headers or `$Context"
        throw $outError
    }
    If ( $workItemsUrl.Length -GT 0 ) 
    {
            #
            # We have the workitems URL, all we need is to add the workItemID value
            #
            $requestURL = $workItemsUrl
        }
        elseIf ( ($project.Length -GT 0 ) -and ($orgUrl.Length -gt 0 ) ) {
                #
                # Build the workitems request URL from the project, organization and the workItemId
                #
                $requestURL = [string]::Format("{0}{1}{2}{3}", $orgUrl, $project, $witSuffix, $workItemID)
                Write-DebugInfo -debugString $requestURL
            }
            else {
                #
                # At this point, if the requestURL has a length greater than 0, then we can add the suffix values to complete the 
                # request.
                # Otherwise, we should throw and argument exception and exit the cmdlet.
                #
                $outError = [string]::Format("Unable to build request URL from input data: project: {0} orgUrl: {1} workItemsUrl: {2}", $project, $orgUrl, $workItemsUrl)
                throw $outError
            }
            if ( $workItemType.Length -gt 0 ) {
                #
                # We have a work item type, add this information and complete the RequestUrl
                #
                $requestURL = [string]::Format("{0}/{1}?{2}", $requestURL, $workItemType, $apiVersion)
                $dbgString = [string]::Format("New-WorkItem - requestUrl: {0}", $requestURL)
                Write-DebugInfo  -debugString $dbgString -ForegroundColor DarkBlue
            }
            else {
                $outError = "Missing workItemType - must have a work item type: ie Task or Initiative etc..."
                throw $outError
            }
            #
            # Now we have a requestUrl, lets add the query parameters
            #
            #$requestURL = [string]::Format("{0}?{1}&`$expand={2}", $requestURL, $apiVersion, $expand)
            $data = @{
                "text" = $commentText
            } | ConvertTo-Json
            try {
                $results = Invoke-RestMethod -Method POST -ContentType "application/json" -Uri $requestURL -Headers $headers -Body $data
            }
            catch {
                Write-Host "An error occurred: $_"
                return $null
            }
            finally {
                <#Do this after the try block regardless of whether an exception occurred or not#>
            }
            return $results
        }