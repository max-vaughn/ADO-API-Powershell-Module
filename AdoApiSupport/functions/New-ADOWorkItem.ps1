function New-ADOWorkItem {
    param(
        [Parameter()]
        [string]  $workItemsUrl = "",
        [string] $baseUrl = $global:strOrgUri,
        [string] $project = "",
        [string] $orgUrl = "",
        [string] $workItemType = $null,
        [PSObject] $operations = $null,
        [hashtable] $headers = $global:gHeaders,
        [ValidateSet( "None", "Relations", "Fields", "Links", "All")]
        [string] $expand = "None",
        [string] $apiVersion = "api-version=6.0"
    )
    $witSuffix = "/_apis/wit/workitems/"
    $requestURL = ""
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
                $requestURL = [string]::Format("{0}{1}{2}", $orgUrl, $project, $witSuffix)
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
                # We have a work item type, add this information and complete the ReqeustUrl
                #
                $requestURL = [string]::Format("{0}`${1}?{2}", $requestURL, $workItemType, $apiVersion, $expand)
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
            $dbgString = [string]::Format("new-ADOworkItem -> requestURL: {0}", $requestURL)
            Write-DebugInfo $dbgString -ForegroundColor DarkBlue
            # 
            # Check to see if we have items to build the body of the create request, if no operations are available
            # Throw an exception
            #
            if( $null -eq $operations )
            {
                throw "No operations to use in the create work item process.  Must have a minimum of 1 property -> /field/System.Title"
            }
            $operation = $null
            foreach( $item in $operations ){
                if( $item.path -eq "/fields/System.Title") { $operation = $item }
            }
            if( $null -eq $operation ) {
                throw "No /fields/System.Title path found in input operations.  Must have one property defined as /fields/System.Title"
            }
            $body = Get-ADOOperationJSON -operations $operations
            Write-DebugInfo -ForegroundColor DarkCyan $requestURL
            Write-DebugInfo -ForegroundColor DarkCyan $body
            $results = Invoke-RestMethod -Method POST -ContentType "application/json-patch+json" -Uri $requestURL -Headers $headers -Body $body
            return $results
        }