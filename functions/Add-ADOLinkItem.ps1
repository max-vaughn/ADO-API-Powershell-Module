# ==================> Function Add-ADOLinkItem <==================

<# 
.SYNOPSIS
Adds a link described by the link* paramaters to a target work item based on the LinkType parameter


.DESCRIPTION
Adds a link described by the link* paramaters to a target work item based on the LinkType parameter
Implements the ADO API located at:
https://docs.microsoft.com/en-us/rest/api/azure/devops/wit/work%20items/update?view=azure-devops-rest-6.1#add-a-hyperlink

With link types discussed at the following link:
https://docs.microsoft.com/en-us/azure/devops/boards/queries/link-type-reference?view=azure-devops




EXAMPLES
# Add Admin Consent for a Delegated Permission
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -PermissionType Delegated -ClaimValue User.Read

# Add User Consent for single user (new OAuth2PermissionGrant)
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -PermissionType Delegated -ClaimValue User.Read -UserId john@contoso.com

# Update User Consent for all users (existing OAuth2PermissionGrant)
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -ConsentType User -PermissionType Delegated -ClaimValue Directory.AccessAsUser.All

# Add Admin Consent for Application Permission
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -PermissionType Application -ClaimValue User.Read.All


.PARAMETER workItemsUrl
full url to the API endpoint for adding a workitem without the parameters 
For example:
https://

.PARAMETER project
Name or project ID for the target project.  Its best to use the project ID instead of the textual name.

.PARAMETER orgUrl
The organizations API url prefix.  Does not contain project or API parameters.

.PARAMETER workItemFullUrl
Full API endpoint URL for the workitem that will have a link added to it

.PARAMETER workItemID
The id for the workitem represented by an interger value

.PARAMETER linkItemId
The ID for the link item, will be used to build the link item's URL for use in the API call

.PARAMETER linkItemsUrl
The URL to the link items base area without any parameters or link id information

.PARAMETER headers
Hashtable containing the HTTP headers to send with the REST request.  Must inlcucde the authentication header value build from the Personal Access Token

.PARAMETER expand
Value for the $expand API parameter

.PARAMETER LinkType
The link type as defined by the ADO API Link Type Preference documentation link

.NOTES
General notes
#>
function Add-ADOLinkItem {

    [CmdletBinding()]
    param (
        [string]  $workItemsUrl = "",
        [string] $project = "",
        [string] $orgUrl = "",
        [string]  $workItemFullUrl = "",
        [string]  $workItemID = "",
        [string]  $linkItemId = "",
        [string]  $linkItemFullUrl = "",
        [string]  $linkItemsUrl = "",
        [ValidateNotNull()]
        [hashtable] $headers = $global:gHeaders,
        [ValidateSet( "None", "Relations", "Fields", "Links", "All")]
        [string] $expand = "None",
        [string] $apiVersion = "api-version=6.0",        
        [ValidateSet( "System.LinkTypes.Hierarchy-Forward",
            "System.LinkTypes.Hierarchy-Reverse",
            "System.LinkTypes.Duplicate-Forward",
            "System.LinkTypes.Duplicate-Reverse",
            "System.LinkTypes.Related",
            "Microsoft.VSTS.Common.Affects-Reverse",
            "Microsoft.VSTS.Common.Affects-Forward")]
        [string] $LinkType = "System.LinkTypes.Hierarchy-Reverse"
    )
    $witSuffix = "/_apis/wit/workitems/"
    $requestURL = ""
    if ( $workItemFullUrl.Length -gt 0 ) {
        #
        # We have the full URL to the work item.
        # Lets build the request URL with that value
        #
        $requestURL = $workItemFullUrl
    }
    elseIf ( ($workItemsUrl.Length -GT 0 ) -and ($workItemID.length -gt 0 )) {
        #
        # We have the workitems URL, all we need is to add the workItemID value
        #
        $requestURL = [string]::Format("{0}/{1}", $workItemsUrl, $workitemID)
    }
    elseIf ( ($project.Length -GT 0 ) -and ($orgUrl.Length -gt 0 ) -and ($workItemID.Length -gt 0 )) {
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
        $outError = [string]::Format("Unable to build request URL from input data: workitemUrl: {0} project: {1} orgUrl: {2} workItemID: {3} workItemFullUrl: {4}", $workItemsUrl, $project, $orgUrl, $workItemID, $workItemFullUrl)
        throw $outError
    }
    $linkURL = ""
    if ( $linkItemFullUrl.Length -gt 0 ) {
        #
        # We have the full URL to the work item.
        # Lets build the request URL with that value
        #
        $linkURL = $linkItemFullUrl
    }
    elseIf ( ($linkItemsUrl.Length -GT 0 ) -and ($linkItemID.length -gt 0 )) {
        #
        # We have the workitems URL, all we need is to add the linkItemID value
        #
        $linkURL = [string]::Format("{0}/{1}", $workItemsUrl, $workitemID)
    }
    elseIf ( ($project.Length -GT 0 ) -and ($orgUrl.Length -gt 0 ) -and ($linkItemID.Length -gt 0 )) {
        #
        # Build the workitems request URL from the project, organization and the workItemId
        #
        $linkURL = [string]::Format("{0}{1}{2}{3}", $orgUrl, $project, $witSuffix, $linkItemID)
        Write-DebugInfo -debugString $linkURL
    }
    else {
        #
        # At this point, if the requestURL has a length greater than 0, then we can add the suffix values to complete the 
        # request.
        # Otherwise, we should throw and argument exception and exit the cmdlet.
        #
        $outError = [string]::Format("Unable to build request URL from input data: workitemUrl: {0} project: {1} orgUrl: {2} workItemID: {3} workItemFullUrl: {4}", $workItemsUrl, $project, $orgUrl, $workItemID, $workItemFullUrl)
        throw $outError
    }
    #
    # Now we have two URIs:
    # $linkUrl - URL for the item to be added as a link
    # $workItemsUrl - url of the item to have the link added to it.
    #
    $body="[
  {
    `"op`": `"add`",
    `"path`": `"/relations/-`",
    `"value`": {
        `"rel`": `"$LinkType`",
        `"url`": `"$linkURL`",
        `"attributes`": {
           `"comment`": `"Making a new link - Add-LinkItem cmdlet`"
          }
        }
  }
  ]"
  $requestURL = [string]::Format("{0}?{1}&`$expand={2}", $requestURL, $apiVersion, $expand)
  $dbgString = [string]::Format("Get-WorkItemById -> requestURL: {0}", $requestURL)
  Write-DebugInfo $dbgString -ForegroundColor DarkBlue
  $results = Invoke-RestMethod -Method Patch -Uri $requestURL -Headers $headers -ContentType "application/json-patch+json" -Body $body
  return $results
}