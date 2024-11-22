<#
==================> Function Update-ADOWorkItem <==================
#>


<#
.SYNOPSIS
Used to update a given work item.

Use the New-ADOCreateOperation cmdlet to build an operation structure with the desired wit values for a given
This method in this version uses the PATCH method to update existing work items with a given set of operation structures.

.PARAMETER $workItemsUrl
Use the Get-ADOUrl cmdlet to retrieve the work items area:

base work items URL, should take the form of:


.Parameter returnBaseUrl
This boolean parameter can be used to return just the locationUrl of organization.  
THe parameter defaults to True.

.PARAMETER apiVersion 
This parameter is present to allow for different versions of an API to be called.
The parameter is initialed to the current API version as of 01/12/2021 to successfully 
execute the target API.

.EXAMPLE
$orgUrls = Get-ADOOrganizationBaseUrl -organization "IdentityCommunities" -returnBaseUrl $false
$orgUrls


id                                   name locationUrl
--                                   ---- -----------
79134c72-4a58-4b42-976c-04e7115f32bf core https://dev.azure.com/IdentityCommunities/

Return the entire core URL strusture including the area ID and the base url

.EXAMPLE
$orgBaseUrl = Get-ADOOrganizationBaseUrl -organization "IdentitiesCommunities"
$orgBaseUrl

https://dev.azure.com/IdentityCommunities/

Return just the base url for the organization

.NOTES
General notes
#>
param(
    [Parameter()]
    [string]  $workItemsUrl = "",
    [string] $project = "",
    [string] $orgUrl = "",
    [string]  $workItemFullUrl = "",
    [string]  $workItemID = "",
    [ValidateNotNull()]
    [hashtable] $headers = $global:gHeaders,
    [ValidateSet( "None", "Relations", "Fields", "Links", "All")]
    [string] $expand = "None",
    [string] $apiVersion = "api-version=6.0"
)
$witSuffix = "/_apis/wit/workitems/"
$requestURL = ""
if( $workItemFullUrl.Length -gt 0 ){
   #
   # We have the full URL to the work item.
   # Lets build the request URL with that value
   #
   $requestURL = $workItemFullUrl
}
elseIf( ($workItemsUrl.Length -GT 0 ) -and ($workItemID.length -gt 0 )){
   #
   # We have the workitems URL, all we need is to add the workItemID value
   #
   $requestURL = [string]::Format("{0}/{1}", $workItemsUrl, $workitemID)
}
elseIf ( ($project.Length -GT 0 ) -and ($orgUrl.Length -gt 0 ) -and ($workItemID.Length -gt 0 )){
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
$outError = [string]::Format("Unable to build request URL from input data: \n\tworkitemUrl: {0}\n\tproject: {1}\n\torganization: {2}\n\tworkItemID: {3}\n\tworkItemFullUrl: {4}\n", $workItemsUrl, $project, $organization, $workItemID, $workItemFullUrl)
throw $outError
}
#
# Now we have a requestUrl, lets add the query parameters
#
$requestURL = [string]::Format("{0}?{1}&`$expand={2}", $requestURL, $apiVersion, $expand)
$dbgString = [string]::Format("Get-WorkItemById -> requestURL: {0}", $requestURL)
Write-DebugInfo $dbgString -ForegroundColor DarkBlue
$results = Invoke-RestMethod -Method Get -Uri $requestURL -Headers $headers
return $results
}