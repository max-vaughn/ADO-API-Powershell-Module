$global:strPersonalToken = ""
$global:strOrgUri = ""
$global:strEncodedPersonalToken = ""
$global:WikiInfo = $null
$global:gHeaders = $null
$global:DefaultContext = $null
[bool]$global:debugCmdlets = $false
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
{
    [CmdletBinding()]
    param (
        [string]  $ScriptFolder = '.\functions',
        [string] $TargetFolder = "."
    )

    return $retVal
}
# ==================> Function Get-ADOContext <==================

<# 

.SYNOPSIS
Using a Personal Access Token and an organization, this cmdlet created a context object for the pat.

.DESCRIPTION
Using a Personal Access Token  and an organization the cmdlet builds a context object for the PAT.

Information about Personal Access Tokens can be found at this link:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

See Outputs for details on the Context object that is returned by this cmdlet.


.PARAMETER pat
Personal Access Token obtained from Azure Dev Ops, see the following link for details on PATs:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

If this parameter is present, it will be used to create the header hashtable.

Either the pat or the tokenHash must have a valure in order to execute this cmdlet.

.PARAMETER organization
parameter contains the target organization that is associated with the pat parameter.
This parameter cannot be null, it must contain an organization name.

.PARAMETER project
parameter represents a target project used to initialize the context object.

.OUTPUTS
The cmdlet outputs a PSCustomObject refered to as the Context object.  
The properties of the contects object are:

   WikiInfo      - Information about any wiki's that the context may contain.  IF a wikiName is provided
                   structure is information about that specific wiki.
    Headers      - Hash table that represents the headers structure for the PAT.  Contains
                   the Authorization Header value with the encoded PAT.
    OrgUrl       - The organization URL used for building API calls including the trailing /
    Project      - Contains the project name used to acquire the ProjectID property of the context.
    ProjectId    - Contains the unique identifier for the project.  Used in building API urls
    Organization - Oganization name for this context.
    Projects     - Collection of projects for the given organization
   
.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"

Retrieve a context object for the Supportability organization, targeting the AzureAD project

.EXAMPLE
$perTok = "<Personal_Access_Token>"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD" -wikiName "AzureAD"

Retreive a context object for the Supportability organization, targeting the AzureAD initializg
the WikiInfo with the AzureAD Wiki

.NOTES
Using this cmdlet, the programmer can build multiple context objects for use in a single script.

For example, an AzureAD Wiki context can be used to create a list of articles.  This list of articles can then 
be used to build a series of ADO work items in another project.

For an example of a cmdlet that does just this type of work, see the New-WorkItemsFromWikiPages 
Get-help New-WorkItemsFromWikiPages 

#>
function Get-ADOContext {
    [CmdletBinding()]
    param (
        [string]$pat,
        [string]$organization,
        [string]$project,
        [string]$wikiName = $null
    )
    #
    # encode the Personal Access Token and create the header hash table
    #
    if($pat.Length -EQ 0 ){
        $outErr = [string]::Format("Get-ADOContext - Personal Access token cannot be null.  Please provide a personal access token")
        throw $outErr
    }
    if( $null -eq $organization)
    {
       $outErr = [string]::Format("Get-ADOContext - organization cannot be null.  Please provide an organization that is associated with the pat")
       throw $outErr
    }
    $perTok = $pat
    $perTok = [System.Convert]::ToBase64String( [System.Text.Encoding]::ASCII.GetBytes(":$pat"))
    $retHash = @{ token = $perTok; org = $orgUrl }
    $adoHeaders = Set-ADOAuthHeaders -tokenHash $retHash
    $res = Get-ADOOrganizationBaseURL -organizationName $organization
    $orgUrl = $res
    $dbgStr = [string]::Format("Get-ADOContext -> *orgUrl :{0}*-*organization: {1}*-*project: {2}*", $orgUrl, $organization, $project )
    Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
    $projs = Get-ADOProjects -organization $organization -headers $adoHeaders
    $projID = Get-ADOProjectID -projects $projs -project $project
    $dbgStr = [string]::Format("Get-ADOContext -> *project:{0}*-*projID: {1}*", $project, $projID )
    Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
    If( $wikiName.Length -gt 0 )
    {
        #
        # There is a specific wiki name for the wikiInfo structure, use it.
        #
        $WikiInfo =  Get-Wikis -baseUrl $orgUrl -Project $projID -wikiName $wikiName -headers $adoHeaders -Organization $organization
    }
    else {
        # 
        # No specific wiki, get all registered wikis
        #
        $WikiInfo = Get-Wikis -baseUrl $orgUrl -organization $organization -project $projID -headers $adoHeaders
        Write-DebugObject -debugString "Get-ADOContext" -inputObject $WikiInfo
    }
    $retContext = New-Object -TypeName PSObject
    $retContext | Add-Member -Name "WikiInfo" -Type NoteProperty -Value $WikiInfo
    $retContext | Add-Member -Name "Headers" -Type NoteProperty -Value $adoHeaders
    $retContext | Add-Member -Name "OrgUrl" -Type NoteProperty -Value $orgUrl
    $retContext | Add-Member -Name "Project" -Type NoteProperty -Value $project
    $retContext | Add-Member -Name "ProjectId" -Type NoteProperty -Value $projID
    $retContext | Add-Member -Name "Organization" -Type NoteProperty -Value $organization
    $retContext | Add-Member -Name "Projects" -Type NoteProperty -Value $projs
    return $retContext
}
function Get-ADOOperationJSON {
    [CmdletBinding()]
    param (
        [Parameter()]
        $operations
    )
    $outJSON = ""
    if ($operations.count -gt 0 ) {
        #
        # its an array of values, build an array of items to return.
        #
        $strBld = [System.Text.StringBuilder]::new("[")
        [void]$strBld.AppendLine()
        $loopCount = 0;
        foreach ( $item in $operations) {
            #
            # Loop through the operations and build the JSON
            #
            [void]$strBld.AppendLine("   {")
            [void]$strBld.AppendFormat("        ""op"": ""{0}"",", $item.op)
            [void]$strBld.AppendLine()
            [void]$strBld.AppendFormat("        ""path"": ""{0}"",", $item.path)
            [void]$strBld.AppendLine()
            if($item.from.length -gt 0 ){
                [void]$strBld.AppendFormat("        ""from"": {0},", $item.from)
                [void]$strBld.AppendLine()
            }
            [void]$strBld.AppendFormat("        ""value"": ""{0}""", $item.value)
            [void]$strBld.AppendLine()
            if ( $loopCount -lt ($operations.count-1)) {
                [void]$strBld.AppendLine("   },")
                $loopCount = $loopCount + 1
            }
            else {
                [void]$strBld.AppendLine("   }")
            }
        }
        [void]$strBld.AppendLine("]")
        $outJson = $strBld.ToString()
    }
    else {
        #
        # its a single item, build a single item return string
        #
        $strBld = [System.Text.StringBuilder]::new()
        [void]$strBld.AppendLine("[")
        [void]$strBld.AppendLine("   {")
        [void]$strBld.AppendFormat("        ""op"": ""{0}"",", $operations.op)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendFormat("        ""path"": ""{0}"",", $operations.path)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendFormat("        ""from"": {0},", $operations.from)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendFormat("        ""value"": ""{0}""", $operations.value)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendLine("   }")
        [void]$strBld.AppendLine("]")
        $outJSON = $strBld.ToString()
        Write-DebugInfo -ForegroundColor DarkRed $strBld.ToString()
    }
    return $outJSON
}
<#
==================> Function Get-ADOOrganizationBaseURL <==================
#>


<#
.SYNOPSIS
Retrieves an organization's base URL that can be used to objectain additional information from
an organziation using APIs.  The cmdlet does not require any special permissions to execute.


.DESCRIPTION
Retrieves the base url for an organization that can be used to build other URLs to
obtain additional data from Azure Dev Ops using the APIs.

Implements the ADO API located at:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#how-to-get-an-organizations-url

Using the core area ID defined in the following link
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#resource-area-ids-reference


.PARAMETER organizationName
The organizationName is a required parameter, it cannot be null.  This value is used to lookup the 
core URL structure defined here:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#how-to-get-an-organizations-url

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
function Get-ADOOrganizationBaseURL
{
    [CmdletBinding()]
    param (
        [string]  $organizationName,
        [bool] $returnBaseUrl = $true,
        [string] $apiVersion = "api-version=5.0-preview.1"
    )
    $requestURL = [string]::Format("https://dev.azure.com/_apis/resourceAreas/79134C72-4A58-4B42-976C-04E7115F32BF?accountName={0}&{1}",$organizationName, $apiVersion)
    $result = Invoke-RestMethod -Method GET -uri $requestURL
    if( $returnBaseUrl ){
        $retVal = $result.locationUrl
    }
    else {
        $retVal = $result
    }
    return $retVal
}
function Get-ADOProcessTemplates {
    param (
        [Parameter()]
        [hashtable]
        $headerProperties,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $orgUrl,
        [ValidateNotNullOrEmpty()]
        [string] $project,
        [string] $Filter
    )
    $processTemplateUrl = [string]::Format("{0}/_apis/work/processadmin?api-version=6.0-preview.1" , $orgUrl)
    Write-DebugInfo -$debugString $processTemplateUrl -ForegroundColor Green
    $results = Invoke-RestMethod -Method Get -Uri $processTemplateUrl -Headers $headerProperties 
    return $results
}
function Get-ADOProjectId {
    param (
        [PSObject] $projects = $null,
        [string] $project = $null,
        [string] $organization = $null,
        [hashtable] $headers = $global:gHeaders
    )
    if ( $null -eq $project ) {
        throw "Missing project name.  Must have a project name to search for."
    }
    else {
        #
        # We have a project ot lookup.
        # We now need either an organization to create projects list
        # Or
        # a projects list
        #
        if ( ($null -eq $projects) -and ($null -eq $organization) ) {
            throw "Must have either an organization or a projects collection from Get-Projects cmdlet"
        }
        elseif( $null -eq $projects ){
            #
            # We know that we have an organization, build the projects list
            # from the organization
            #
            elseif ( $null -eq $organization ) { 
                throw "Missing project and organization, must have one or the other"
            }
            $srcList = Get-ADOProjects -organization $organization -headers $headers
        }
        else {
            #
            # Work with the current projects list
            #
            $srcList = $projects
        }
        $projectID = ""
        $global:SomeList =  $srcList
        foreach( $item in $srcList ){
            if( $item.name -eq $project )
            {
                $projectID = $item.id
                Write-Host $item
                $dbgStr = [string]::Format("Get-ADOProjectId -> PROJECT NAME MATCH *project:{0}*-*Project ID: {1}", $item.name, $item.id )
                Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
                break;
            }
        }
        $dbgStr = [string]::Format("Get-ADOProjectId -> *project:{0}*-*Project ID: {1}", $project, $projID )
        Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
        return $projectID
        }
        return $null
}
<#
==================> Function Get-ADOProjects <==================
#>


<#
.SYNOPSIS
Retrieves all of the projects that are defined in an organization.
Requires a Personal Access Token represented in the Authorization header value in the 
headers parameter.


.DESCRIPTION
Retrieves the projects that are part of the given organization.  
Requires a Personal Access Token represented in the Authorization header value in the 
headers parameter.

Implements the ADO API located at:
https://docs.microsoft.com/en-us/rest/api/azure/devops/core/projects/get?view=azure-devops-rest-6.0

.PARAMETER organization
Contains the organization to use to lookup the organization base url if the orgBaseUrl parameter is null.
core URL structure defined here:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#how-to-get-an-organizations-url

Either the orgBaseUrl or the organization paramater must be present to succefully execute this cmdlet.

.Parameter orgBaseUrl
Represents the base url for the organization.  If this parameter is present, the organization paramer is ignored
and the API call is built from this base url.

If this parameter is null, then the organization parameter must be present.  In this scenario,
the Get-ADOOrganizationBaseUrl is used to obtain the organization's base url.

.PARAMETER apiVersion 
This parameter is present to allow for different versions of an API to be called.
The parameter is initialed to the current API version as of 01/12/2021 to successfully 
execute the target API.

.PARAMETER headers
Hashtable containing the headers that will be added to the Invoke-RestMethod cmdlet.  The header must 
contain the Authorization header value.  Use the Set-ADOAuthHeaders cmdlet with a Personal Access Token to 
create a header hashtable.

.OUTPUTS
The cmdlet returns a collection of projects as defined by the following documentation link:
https://docs.microsoft.com/en-us/rest/api/azure/devops/core/projects/get?view=azure-devops-rest-6.0#teamproject

Each project is represented by a TeamProject object.


.EXAMPLE


Return the projects based on a organization name.

.EXAMPLE

Return the projects based on the orgBaseUrl

.EXAMPLE


Return the projects base on a specific ADO Context object

.NOTES
General notes
#>
function Get-ADOProjects{
    [CmdletBinding()]
    param (
        [string] $organization = $null,
        [hashtable] $headers = $global:gHeaders,
        [string] $orgBaseUrl = $null,
        [string] $apiVersion = "api-version=6.1-preview.4"
    )
    $requestURL = ""
    if( $orgBaseUrl.Length -gt 0 ){
        #
        # We have a base URL discoved using the 
        # Get-OranizationBaseUrl cmdlet
        # Start building the requestUrl
        #
        $requestURL = $orgBaseUrl
    }
    elseif( $organization.Length -gt 0 ){
        #
        # We have an organization, call the Get-OranizationBaseUrl to 
        # obtain the URLbase to get the projects
        #
        $res = Get-ADOOrganizationBaseURL -organizationName $organization
        $requestUrl = $res
        $dbgStr = [string]::Format("Get-ADOProjects: requestUrl-> {0}", $requestURL)
        Write-DebugInfo -debugString $dbgStr -ForegroundColor DarkBlue
    }
    else {
        #
        # We don't have enough informaiton to get the base URL, so throw an exception.
        #
        throw [string]::Format("Unable to obtain Project ID, missing information, both organization and orgBaseUrl are empty.")
    }
    $requestURL = [string]::Format("{0}_apis/projects?{1}", $requestURL, $apiVersion)
    $dbgStr = [string]::Format("Get-ADOProjects: requestUrl-> {0}", $requestURL)
    Write-DebugInfo -debugString $dbgStr -ForegroundColor DarkBlue
    $result = Invoke-RestMethodWithPaging -Method GET -Uri $requestUrl -Headers $headers
    $projects = $result.value
    $dbgStr = [string]::Format("Get-ADOProjects: Number of Projects-> {0} **", $result.count)
    Write-DebugInfo -debugString $dbgStr -ForegroundColor DarkBlue
    return $projects
}
# ==================> Function Get-ADOUrl <==================

<# 
.SYNOPSIS
Retrieves the API endpoints for a given organization based on the AreaID
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#urls-returned-in-rest-apis

Using the Area IDs defined in the following link:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#resource-area-ids-reference 

.DESCRIPTION
Retrieves the API endpoints for a given organization.
Implements the ADO API located at:
https://docs.microsoft.com/en-us/azure/devops/boards/queries/link-type-reference?view=azure-devops

Using the Area IDs defined in the following link
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#resource-area-ids-reference


.PARAMETER organization
The organization name. This value will be used to obtain the base org url and return the URL based 
on the Area ID.  This parameter is used in the following scenarios

If the orgUrl parameter is null, then this parameter is used  in the Get-ADOOrganizationBaseURL cmdlet
to retrieve the area id. 

IF the orgUrl has a value, this parameter is ignored and the orgUrl is used to retrieve the area url.

.PARAMETER orgUrl
full url to the API endpoint for adding a workitem without the parameters 
For example:
https://supportability.visualstudio.com/
or
https://dev.azure.com/IdentityCommunity/

The organization URL can be obtained using the Get-ADOOrganizationBaseURL

If the orgUrl is null and the organization parameter has a value, the Get-ADOOrganizationBaseURL
cmdlet is used to retreive the ADOUrl based on the area for the organization.

Either the orgUrl or the organizaton name must be present for the cmdlet to return the area url

.PARAMETER header
Hashtable containing the headers that will be added to the Invoke-RestMethod cmdlet.  The header must 
contain the Authorization header value.  Use the Set-ADOAuthHeaders cmdlet with a Personal Access Token to 
create a header hashtable.

.PARAMETER AreaId
Full API endpoint URL for the workitem that will have a link added to it


.EXAMPLE
$perTok = "<Personal_Access_Token"
$headers = Set-ADOAuthHeaders -pat $perTok
$areaUrl = Get-ADOURL -header $headers -organiaztion "IdentityCommunities"


.NOTES
General notes
#>
function Get-ADOURL {
    param (
        [string]$orgUrl = $null,
        [string]$organization = $null,
        [hashtable]$header,
        [string]$AreaId
    )
    if( ($null -eq $orgUrl) -and ($null -eq $organization )) 
    {
        $dbgError = "orgUrl and organization paramerters are both null.  Must have either a orgUrl or an oganization to successfully execute this cmdlet"
        throw $dbgError
    }
    if( $orgUrl.Length -gt 0 ) 
    {
        $orgResorceAreasUrl = [string]::Format("{0}_apis/resourceAreas/{1}?api-preview=5.0-preview.1" , $orgUrl, $AreaId)
    }
    else {
        $tmpUrl = Get-ADOOrganizationBaseURL -organizationName $organization
        $dbgStr = [string]::Format("Get-ADOURL : tempUrl-> {0}", $tmpUrl)
        Write-DebugInfo -ForegroundColor DarkCyan -debugString $dbgStr
        $orgResorceAreasUrl = [string]::Format("{0}_apis/resourceAreas/{1}?api-preview=5.0-preview.1" , $tmpUrl, $AreaId)
    }
    Write-DebugInfo -ForegroundColor DarkCyan -debugString $orgResorceAreasUrl
    $results = Invoke-RestMethod -Uri $orgResorceAreasUrl -Headers $header
    Write-DebugInfo $results -ForegroundColor Green
    if ( "null" -eq $results ) {
        $areaUrl = $orgUrl
    }
    else {
        $areaUrl = $results.locationUrl
    }
    return $areaUrl
}
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
function Get-PageStatsFromCSV {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSObject] $pageInfo = $null,
        [string] $Path = $null,
        [string] $wikiUri = $global:WikiInfo.url,
        [hashtable] $headers = $global:gHeaders,
        [string] $numberDaysFromToday = "7",
        [string] $apiVersion = "api-version=6.0-preview.1",
        [bool] $returnTotalCountOnly = $false,
        [bool] $returnPageIDsAndHitsOnly = $true
    )
    #
    # THe Csv file format should have a property column call id that contains the page id.
    # using the id property matches the APIs.  However, a check is made to see if there is a column call PageID as well
    #
    if(( $null -eq $pageInfo ) -and ( $null -eq $path )) {
        $strError = "Both pageInfo and Path cannot be null, cmdlet requires one of these parameters"
        throw $strError
    }
    elseif( $null -eq $pageInfo ) { $pageData = Import-CSV -Path $Path }
    else { $pageData = $pageInfo }
    $propName = [string]::Format("Views In Last {0} days", $numberDaysFromToday)
    $retObjects = @()
    if ( $null -ne $pageData[0].id ) {
        #
        # pageData is similiar to a pageInfo structure, use the id field as the page number
        #
        foreach ($item in $pageData) {
            $hits = Get-WikiPageStats -wikiUri $wikiUri -pageId $item.id -numberDaysFromToday $numberDaysFromToday -returnTotalCountOnly $true -headers $headers
            #
            # Decide if the cmdlet returns an array of objects with just the pageIDs and hits
            #
            # Or return the CSV row object adding the PageIDs and hits
            #
            if ( $returnPageIDsAndHitsOnly -eq $true ) { 
                $retItem = new-object PSObject   
                $retItem | Add-Member -Name "pageID" -MemberType NoteProperty -Value $item.id
            }
            else { $retItem = $item }  
            $retItem | Add-Member -Name $propName -MemberType NoteProperty -Value $hits
            $retObjects = $retObjects + $retItem
            $retItem = $null
        }
    } 
    elseIf ( $null -ne $pageData[0].pageID ){
        #
        # pageID property found in the data, use pageID to retrieve data
        #
        foreach ($item in $pageData) {
            $hits = Get-WikiPageStats -wikiUri $wikiUri -pageId $item.pageID -numberDaysFromToday $numberDaysFromToday -returnTotalCountOnly $true -headers $headers
            #
            # Decide if the cmdlet returns an array of objects with just the pageIDs and hits
            #
            # Or return the CSV row object adding the PageIDs and hits
            #
            if ( $returnPageIDsAndHitsOnly -eq $true ) { 
                $retItem = new-object PSObject   
                $retItem | Add-Member -Name "pageID" -MemberType NoteProperty -Value $item.pageID
            }
            else { $retItem = $item }  
            $retItem | Add-Member -Name $propName -MemberType NoteProperty -Value $hits
            $retObjects = $retObjects + $retItem
            $retItem = $null
        }
    }
    else {
        $outError = [string]::Format(" Path: {0} CSV File is not the expected format or the pageInfo collection parameter does not contain the id field", $path)
        throw $outError
    }
    return $retObjects
}
<#
Get-WikiFolderDocs takes the output of Get-WikiPages with a folder URL and returns a flat list of MD files ( not folder files ) 
    within the folder information.  If the folder information contains sub folders, these folders are traversed if the subpages attribute 
    is set.

    The cmdlet uses the Get-WikiPage cmdlet to retrieve a folder at onelevel, then when it encounters another folder, it calls itself on that folder
    path.

    The function returns the url of none folder items ( basically checking the IsParentPage != true )

    The returned hash table has the following form:
    returnMDFiles {
        url = <URL from the folder data>
    }
#>
Function Get-WikiFolderDocs {
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
        [string] $apiVersion = "api-version=6.0-preview.1",
        [bool]$includeContent = $false,
        [bool]$returnPageInfo = $false,
        [bool]$foldersOnly = $false
    )
    #
    # Retrieve the initial collection of pages and folders.
    # If $_.isParentPage is true, then the item is a folder and may need to be recursed 
    # depending on the value of $recursionLevel
    #
    $itemCollection = Get-WikiPage -wikiUri $wikiUri -wikiPageFullUrl $wikiPageFullUrl -headers $headers -basePath $basePath -apiVersion $apiVersion -recursionLevel oneLevel
    if( $global:debugCmdlets -eq $true )
    {
        $outstr = write-output $itemCollection
        $dbgString = [string]::Format("Get-WikiFoldersDocs-> itemCollection : {0}", $outstr)
        Write-DebugInfo $dbgString -ForegroundColor DarkBlue
    }
    $itemCollection.subpages | ForEach-Object {
        # 
        # Loop through the items in the collection.  Check to see if the
        # recursion level is the folder base or the full tree, 
        # $recursionlevel == oneLevel repsesents a base folder search.
        # $recursionlevel == full represetns a full tree search including sub folders.
        #
        if ( $recursionlevel -eq "onelevel") {
            if (( $_.isParentPage -eq $true ) -and ( $foldersOnly -eq $true )) {
                if ( $returnPageInfo ) {
                    #
                    # Return the entire page information object from the Get on the wiki page
                    #
                    $resPage = Get-WikiPage -wikiPageFullUrl $_.url -headers $headers
                    $val = $_
                    $val | Add-Member -Name "ID" -Type NoteProperty -Value $resPage.ID
                    $val
                }
            }
           elseif ( $_.isParentPage -eq $true) {  
               #do Nothing with a parent item at oneLevel}
           }
           else {
               if( $returnPageInfo ) {
                   #
                   # Return the entire page information object from the Get on the wiki page
                   #
                   $resPage = Get-WikiPage -wikiPageFullUrl $_.url -headers $headers
                   $val = $_
                   $val | Add-Member -Name "ID" -Type NoteProperty -Value $resPage.ID
                   $val
               }
               else {
                   #
                   # Return just the URL
                   #
                   $_.url
               }
            } 
        }
        else {
            #
            # $recursionLevel == full
            # The request is to deliver all of the items in the base folder
            # along with the entire tree
            #
            If ($_.isParentPage -eq $true) { 
                Get-WikiFolderDocs -wikiPageFullUrl $_.url -headers $headers -apiVersion $apiVersion -returnPageInfo $returnPageInfo
            }
            else {

                if ( $returnPageInfo -eq $true ) {
                    #
                    # Return the entire page information object from the Get on the wiki page
                    #
                    $resPage = Get-WikiPage -wikiPageFullUrl $_.url -headers $headers
                    $val = $_
                    $val | Add-Member -Name "ID" -Type NoteProperty -Value $resPage.ID
                    $val
                }
                else {
                    #
                    # Return just the URL
                    #
                    $_.url
                } # end recursion if block
            } # end checking for onelevel block
        }
    } # end of ForEach-Object block
}
function Get-WikiPage {
    [CmdletBinding()]
    param (
        [Parameter()]
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
    $results = Invoke-RestMethod -Uri $wikiPage -Headers $headers
    $outStr = write-output $results
    $dbgString = [string]::Format("Get-WikiPage -> Results:{0}", $outStr)
    Write-DebugInfo $dbgString -ForegroundColor DarkCyan
    return $results
}
function Get-WikiPageIdFromTagPage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $wikiUri = "",
        [hashtable] $headers,
        [string] $projectId,
        [string] $apiVersion = "api-version=6.0",
        [PSCustomObject] $pageInfo = $null
    )
    #
    # Check to see if we have an object that represents a specific
    # wiki page.  If the object is not null, then we chack the url property
    # if the pageInfo.Content value, if the content is present, proceed with parsing, assuming 
    # that the content is in the form of a tag page in the CSS Wiki
    # 
    if ( $pageInfo -ne $null ) {
        if ( $pageInfo.content.Length -gt 0 ) {
            # 
            # the object has content.  Assume its an MD file in the form of
            # all other tag md files.  Find the  lines starting with " -"
            # and parse out the wiki file names
            #
            $strReader = new-object System.IO.StringReader -ArgumentList $pageInfo.Content
            $urlLines = @();
            do {
                $line = $strReader.ReadLine()
                if ( $line -ne $null ) {
                    if ( $line.Length -gt 4 ) {
                        if ( $line.IndexOf(" -", 0, 4) -eq 0 ) {
                            $urlLines += $line
                        }
                    
                    }
                }
                else {
                    break
                }

            } while ( $true )
            #
            # Check to see if there were any lines collected
            #
            $pagePaths = @()
            if ( $urlLines.Count -gt 0 ) {
                foreach ( $item in $urlLines ) {
                    #
                    # If the item lengt is greater than 3 continue to parse
                    # Replacing hex characters with appropriate values and 
                    # removing the - characters
                    #
                    if ( $item.Length -gt 3 ) {
                        #
                        # Find the first closing bracket so we can parse
                        # the relative link part of the MD link syntax line.
                        #
                        $closeBracket = $item.IndexOf("]", 0)
                        if ( $closeBracket -gt 0) {
                            $openPren = $item.IndexOf("(" , $closeBracket)
                            $closePren = $item.IndexOf(")", $openPren)
                            $pathValue = $item.Substring( $openPren + 1, ($closePren - $openPren - 1))
                            #
                            # Change - to space
                            #
                            $pathValue = $pathValue.Replace("-", " ")
                            #
                            # Change %2D to "-"
                            #
                            $pathValue = $pathValue.Replace("%2D", "-")
                            #
                            # Change &#40 to "("
                            #
                            $pathValue = $pathValue.Replace("&#40;", "(")
                            #
                            # Change &#41 to ")"
                            #
                            $pathValue = $pathValue.Replace("&#41;", ")")
                            $pagePaths += $pathValue
                            Write-DebugInfo -ForegroundColor DarkCyan "pathValue- $pathValue"
                        } # end of checking $closeBracket
                    } # end of checking to see if the item is the appropirate length
                } # End of foreach loop processing lines
            }# End of loop to check if we have data to parse
            # 
            # Check to see if we have URLs in the array.  If so, lets get thier page IDs
            #
            $pageIds = @()
            if ( $pageInfo.isParentPage -eq $true ) {
                $tmpPaths = @()
                foreach ( $item in $pagePaths) {
                    if ( $item.IndexOf('/', 0, 1) -eq -1 ){
                        $tmp = $item
                        if( $tmp.IndexOf(".md") -gt 0) {  
                            $tmp = $tmp.Substring(0, ($tmp.IndexOf(".md")))
                        }
                        $tmp = [string]::Format("{0}{1}", $pageInfo.path, $tmp.SubString($tmp.IndexOf("/")))
                        $tmpPaths += $tmp
                    }
                    else {
                        $tmpPaths += $item
                    }
                }
                $pagePaths = $tmpPaths
            }
            
            if ( $pagePaths.Count -gt 0 ) {
                foreach ( $path in $pagePaths ) {
                    write-Host -ForegroundColor DarkYellow "path - $path"
                    $wikiPage = Get-WikiPage -wikiUri $wikiUri  -headers $headers -includeContent $false -basePath $path
                    if ( $wikiPage.id -gt 0 ) {
                        $wikiId = $wikiPage.Id
                        Write-DebugInfo -ForegroundColor DarkYellow "PageId: $wikiId"
                        $pageUri = [string]::Format("{0}?pageID={1}", $wikiUri, $wikiPage.id)
                        $pageUri = $pageUri.Replace("/_apis/wiki", "/_wiki")
                        Write-DebugInfo -ForegroundColor DarkGreen "pageUri $pageUri"
                        $pageStats = Get-WikiPageStats -wikiUri $wikiUri -headers $headers -numberDaysFromToday 30 -returnTotalCountOnly $true -pageId $wikiId
                        $pageInfo = New-Object -TypeName PSObject
                        $pageInfo | Add-Member -Name "pageId" -Type NoteProperty -Value $wikiPage.id
                        $pageInfo | Add-Member -Name "pagePath" -Type NoteProperty -Value $path
                        $pageInfo | Add-Member -Name "pageUri" -Type NoteProperty -Value $pageUri
                        $pageInfo | Add-Member -Name "Hits last 30 days" -Type NoteProperty -Value $pageStats
                        $pageInfo | Add-Member -Name "getItemPath" -Type NoteProperty -Value $wikiPage.gitItemPath
                        $pageIds += $pageInfo

                    }
                }
                return $pageIds
            }

        }

    }

}
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
        [string] $apiVersion = "api-version=6.0-preview.1",
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
        Write-DebugInfo -debugString DarkBlue $dbgStr
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
    $results = Invoke-RestMethod -Uri $requestURL -Headers $headers
    $dbgStr  = [string]::Format("Get-Wikis -> Exit Function")
    Write-DebugInfo -ForegroundColor DarkYellow $dbgStr
    return $results
}
function Get-WorkItemById {
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
<#
==================> Function Invoke-RestMethodWithPaging <==================
#>


<#
.SYNOPSIS
Invokes a REST request and checks the return header values x-ms-continuationToken 
value to see if another request should be sent


.DESCRIPTION
Invokes a rest request and implements an ADO APi paging method examing the values in the
x-ms-continuationToken return header value to see if another request needs to be made.  

Requests continue to be sent until the x-ms-continuationToken is not returned.

.PARAMETER Method
Rest METHOD to execute expected to be the GET method to generate a complete list for the API URI
based on the ADO API paging mechanisms.

.Parameter Uri
ADO API to execute without the continuationToken parameter

.PARAMETER Headers
Hashtable containing the headers that will be added to the Invoke-RestMethod cmdlet.  The header must 
contain the Authorization header value.  Use the Set-ADOAuthHeaders cmdlet with a Personal Access Token to 
create a header hashtable.

.OUTPUTS
Combinded results from a given ADO api call


.EXAMPLE


NA

.EXAMPLE

NA

.NOTES
General notes
#>
function Invoke-RestMethodWithPaging {
    param(
     [string] $Method,
     [string] $Uri,
     $Headers
    )
    $result = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -ResponseHeadersVariable resHeaders
    $continuationToken = $resHeaders['x-ms-continuationtoken']
    while( $continuationToken -ne $null )
    {
       $uric = [string]::Format("{0}&continuationToken={1}", $Uri, [string]$continuationToken)
       $dbgStr = [string]::Format("Invoke-RestMethodWithPaging: *Url-> {0}* *continuationToken -> {1}*", $uric, [string]$continuationToken)
       Write-DebugInfo -debugString $dbgStr -ForegroundColor DarkMagenta
       $result2 = Invoke-RestMethod -Method $Method -Uri $uric -Headers $Headers -ResponseHeadersVariable resHeaders
       $continuationToken = $resHeaders['x-ms-continuationtoken']
       $result.Value = $result.Value + $result2.Value
       $dbgStr = [string]::Format("Invoke-RestMethodWithPaging: *returned objects-> {0}* *Total Objects-> {1}* *continuationToken -> {2}*", $result2.count, $result.count, [string]$continuationToken)
       Write-DebugInfo -debugString $dbgStr -ForegroundColor DarkMagenta
    }
    return $result
 }
 
function new-ADOCreateOperation {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $operation,
        [string] $value,
        [string] $from = "",
        [string] $path = ""
    )
    $retItem = New-Object PSobject
    $retItem | Add-Member -Name "op" -Value $operation -MemberType NoteProperty
    $retItem | Add-Member -Name "value" -Value $value -MemberType NoteProperty
    $retItem | Add-Member -Name "from" -Value $from -MemberType NoteProperty
    $retItem | Add-Member -Name "path" -Value $path -MemberType NoteProperty    
    return $retItem
}
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
# ==================> Function New-ReplacementItem <==================

<# 

.SYNOPSIS
This cmdlet created replacement items that can be used with the New-WorkItemsFromWikiPages

.DESCRIPTION
This cmdlet will create replacement items that can be used withthe New-WorkItemsFromWikiPages to update
description properties of work items with wiki page specific data.

The description replacement process allows the programmer to define tags in the description text and then 
associate a to text.  In the New-WorkItemsFromWikiPages cmdlet, there is logic that will associate the FromTag with a 
specific property in the wiki pages information.  Currently the ID ( page ID ) and the gitItemPath are supported by using the 
syntax item.ID and Item.gitItemPath in the ToValue of the replacement item.


.PARAMETER FromTag
String to search for in the description template, once found, will be replaced with the ToValue

.PARAMETER ToValue
When a FromTag is found, then it is replaced with this value.  The New-WorkItemsFromWikiPages supports two
property tags that are associated with the Wike Page:

Item.ID - the pageID value for the wiki page
Item.gitItemPath - the path to the file in the folder

These properties are described in the following link:
https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get?view=azure-devops-rest-5.0#wikipage

With the adde property ID that contains the page ID value obtained by calling the API:
https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get%20page%20by%20id?view=azure-devops-rest-6.0

And adding the ID value to the wikpage structure for obtaining multiple pages.

.OUTPUTS
PSObject that contains two properties:
   FromTag - tag to find and replace
   ToValue - replacement text for the tag

.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$headers = Set-ADOAuthHeaders -pat $perTok

Creating an array of Replacement items

.EXAMPLE

$LocalTokenHash = @{ token = $global:strEncodedPersonalToken; org = $global:strOrgUri }
$headers = Set-ADOAuthHeaders -tokenHash $localTokenHash

Using an existing tokenHash table create a header struction.
.EXAMPLE 
$perToken = "<Personal_Access_Token>"
$heasers = SetADOAuthHeaders -curHeader $existingHeaders -pat $perToken

Update an existing header structure with a new Personal Access Token

.NOTES
General notes
#>
function new-replacementItem {
    param(
    [string] $FromTag,
    [string] $ToValue
    )
    $retItem = new-object  -TypeName PSObject
    $retItem | Add-Member -Name "FromTag" -Type NoteProperty -Value $FromTag
    $retItem | Add-Member -Name "ToValue" -Type NoteProperty -Value $ToValue
    return $retItem
}

function Get-WorkItemDescription {}

function Write-HTMLliFromPageInfo {
param (
    [PSObject] $pageInfo,
    [string] $wikiUrl
)
$retVal = [System.Text.StringBuilder]::new("")
foreach( $page in $pageInfo){
    $lastSlash = $page.path.LastIndexOf('/')
    $FileName = $page.path.SubString( $lastSlash+1 )
    $pageUrl = [String]::Format("{0}?pageId={1}", $wikiUrl, $page.ID)
    $htmlListItem = [System.Text.StringBuilder]::new("")
    $htmlListItem.AppendFormat("<li><a href=""{0}"" title=""{1}"">{1}</a></li>", $pageUrl, $FileName)
    [void]$retVal.AppendLine( $htmlListItem.ToString())
}
return $retVal.ToString()

}
       # $res = Get-WikiFolderDocs -basePath "GeneralPages/AAD/Developer" -wikiUri $WikiInfo.url -headers $gHeaders -returnPageInfo $true 
        # New-WorkItemsFromWikiPages -wikiPages $res -Context $DevExpContext -areaPath "Community - Identity Developer Experiences \\Troubleshooting Guides" -titlePrefix "[WK] MBI Template Update: " -description "$desText" -ReplaceTemplates $repItems -ParentLinkPath $linkUrl -workItemType task -iterationPath $iterationPath   

        function New-WorkItemsFromWikiPages {
            param (
                [Parameter()]
                $wikiPages = $null,
                $Context,
                [string] $areaPath = $null,
                [string] $iterationPath = $null,
                [string] $titlePrefix = $null,
                [string] $description = $null,
                [PSObject] $ReplaceTemplates = $null,
                [string] $ParentlinkPath = $null,
                [string] $workItemType = $null
            )
            if ( $wikiPages -eq $null ) {
                $outErr = [string]::Format("Missing PSObject information for list of pages.  Must the output of Get-WikiFoldersDocs with -returnpageInfo set to `$true")
                throw $outErr
            }
            else {
                foreach ( $item in $wikiPages) {
                    $properties = @()
                    $itemName = $item.gitItemPath
                    $itemName = $itemName.SubString($itemName.LastIndexOf('/') + 1)
                    #
                    # Create the title for the work item and 
                    # add the add operation to the properties list
                    #
                    if ( $titlePrefix.Length -GT 0 ) {
                        #
                        # The user has provided a prefix for the title.
                        # Build the title [$titlePrefix] - [.MD File name]
                        #
        
                        $itemName = [string]::Format("{0} - {1}", $titlePrefix, $itemName)
                        $property = new-ADOCreateOperation -Operation add -Path "/fields/System.Title" -Value $itemName -From "null"
                        $properties = $properties + $property
                    }
                    else {
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.Title" -Value $itemName  
                        $properties = $properties + $property
                    }
                    if ( $areaPath.Length -GT 0 ) {
                        #
                        # There is an Area Path value, add this value to the properities list as well.
                        #
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.AreaPath" -Value $areaPath 
                        $properties = $properties + $property
                    }
                    if( $iterationPath.Length -gt 0 ) {
                                                #
                        # There is an iteration Path value, add this value to the properities list as well.
                        #
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.IterationPath" -Value $iterationPath 
                        $properties = $properties + $property
                    }
                    if ( $description.Length -GT 0 ){
                        #
                        # There is a description to add Check to see if there
                        # is a ReplaceTemplates array that contains a list of objects
                        # with properties:
                        # FromTag = "String Tag Value"
                        # ToValue = "Item.property" where propertie is a wikiPage property value
                        # https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get%20page%20by%20id?view=azure-devops-rest-6.0#wikipage
                        # currently the only one supported is page ID
                        # 
                        # Other wise a straght substition will be done.
                        $tmpDescription = $description
                        if( $null -ne $ReplaceTemplates ){
                            #
                            # There is a replacement item in the templates,
                            # roll through all the objects and do a string.Replace operation
                            #
                            foreach( $template in $ReplaceTemplates )
                            {
                                if( $template.ToValue -eq "Item.ID" )
                                {
                                  $tmpDescription = $tmpDescription.Replace($template.FromTag, $item.ID )
                                }
                                elseif ($template.ToValue -eq "Item.gitItemPath" ) 
                                {
                                    $tmpDescription = $tmpDescription.Replace($template.FromTag, $item.gitItemPath )
                                    $dbgString = [string]::Format(" Create-WorkItemsFromWikiPages: Item.gitItemPath: {0} Match: *{1}*", $item.gitItemPath, $template.FromTag)
                                    Write-DebugInfo -ForegroundColor DarkMagenta -debugString $dbgString
                                }
                                else 
                                {
                                    $tmpDescription = $tmpDescription.Replace($template.FromTag, $template.Value )
                                }
                            }
                        }
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.Description" -Value $tmpDescription
                        $properties = $properties + $property
                        $global:gProperties = $properties
                }
                $wrkItem = new-ADOworkitem -Operations $properties -Project $context.ProjectID -orgUrl $context.OrgUrl -baseUrl $context.OrgUrl -headers $Context.Headers -workItemType $workItemType
                if( $ParentlinkPath.Length -gt 0 ){
                    # 
                    # We have a parent item to link this item with.
                    # Create the to the parent item
                    #
                   $retItem =  Add-ADOLinkItem -linkItemFullUrl $ParentlinkPath -workItemFullUrl $wrkItem.url -headers $Context.Headers
                }
        
            }
        }
    }
function Remove-Repo {
    param (
        [string] $repoId, 
        [string] $baseUrl,
        [hashtable] $header
    )
    $deleteRepoUri = [string]::Format("{0}_apis/git/repositories/{1}?api-version=6.0", $baseUrl, $repoId)
    Write-DebugInfo $deleteRepoUri -ForegroundColor DarkMagenta
    $results = Invoke-RestMethod -Method Delete -Uri $deleteRepoUri -Headers $header
    return $results 
}
function Remove-Wiki {
    param (
        [string] $wikiUri, 
        [hashtable] $header
    )
    $deleteWikiUri = [string]::Format("{0}?api-version=6.0", $wikiUri)
    Write-DebugInfo $deleteWikiUri -ForegroundColor DarkMagenta
    $results = Invoke-RestMethod -Method Delete -Uri $deleteWikiUri -Headers $header
    return $results 
}
# ==================> Function Set-ADOAuthHeaders <==================

<# 

.SYNOPSIS
This cmdlet creates a header hashtable that can be used with an Invoke-RestMethod request
and provides at a minimum, the Authorization header value.

.DESCRIPTION
Using a Personal Access Token or a hashtable that contains the encoded access token, 
the cmdlet will create a hashtable that contains header values that can be used with
an Invoke-ResthMothod which executes an Azure Dev Ops API.

Information about Personal Access Tokens can be found at this link:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page


.PARAMETER pat
Personal Access Token obtained from Azure Dev Ops, see the following link for details on PATs:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

If this parameter is present, it will be used to create the header hashtable.

Either the pat or the tokenHash must have a valure in order to execute this cmdlet.

.PARAMETER curHeader
Parameter that contains the current header values.  If present, either the encoded pat paramer or the tokenhash parameter will 
be used to fill the Authorization header value for the returned hash table.  This is a way to use an existing set of 
header values and just replace the Authorization portion of the header values.

.PARAMETER header
Hashtable containing the headers that will be added to the Invoke-RestMethod cmdlet.  The header must 
contain the Authorization header value.  Use the Set-ADOAuthHeaders cmdlet with a Personal Access Token to 
create a header hashtable.

.OUTPUTS
Hashtable for the Authentication header value:
$header = @{Authorization = "Basic " + $localHash.token }
.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$headers = Set-ADOAuthHeaders -pat $perTok

Using a personal access token, create a header structure

.EXAMPLE

$LocalTokenHash = @{ token = $global:strEncodedPersonalToken; org = $global:strOrgUri }
$headers = Set-ADOAuthHeaders -tokenHash $localTokenHash

Using an existing tokenHash table create a header struction.
.EXAMPLE 
$perToken = "<Personal_Access_Token>"
$heasers = SetADOAuthHeaders -curHeader $existingHeaders -pat $perToken

Update an existing header structure with a new Personal Access Token

.NOTES
General notes
#>
function Set-ADOAuthHeaders {
    [CmdletBinding()]
    param (
        [string] $pat = $null,
        [hashtable] $tokenHash = $null,
        [hashtable] $curHeader
    )
    $localHash = $null
    if( $null -ne $pat )
    {
        #
        # We have a PAT, lets endcode it and put it into a token hashtable
        #
        $encodedPat = [System.Convert]::ToBase64String( [System.Text.Encoding]::ASCII.GetBytes(":$global:strPersonalToken"))
        $localHash = @{ token = $encodedPat; org = "" }

    }
    if( $null -ne $tokenHash )
    {
        #
        # There is an existing token hash to use.  Use it
        #
        $localHash = $tokenHash
    }
    if( $null -ne $locaHash )
    {
        #
        # There is no PAT or Token Hash, this is a problem.  One or the other must be present.
        # Throw an exception.
        #
        $outStr = [string]::Format("Must have a Personal Access Token ( pat parameter ) or a TokenHash that contains the encoded PAT ( tokenHash ) both are NULL")
        throw $outStr
    }
    if ( $null -ne $curHeader.Authorization ) {
        $curHeader.Authorization = "Basic " + $localHash.token
        $header = $curHeader
    }
    else {
        $header = @{Authorization = "Basic " + $localHash.token }
    }
    Write-DebugInfo $header.Authorization -ForegroundColor DarkYellow
    return $header

}
#
# Set-ADOGlobals - use this cmdlet if you want to set some defaults for the module.
#   once used, the Global variables:
#      strEncodedPersonalToken - teh encoded personal token retrieved from a web intance of ADO
#      strOrgUri - organization base URI
#
# A hash table is created that can be used as that can be passed to other cmdlets to make it easy to 
# have multiple hashed tokens for different organizations.
#
# ==================> Function Set-ADOGlobals <==================

<# 

.SYNOPSIS
This takes information from the Context parameter and sets default global variables.

.DESCRIPTION
Using the output from the Get-ADOContext cmdlet, this cmdlet sets some global varialbes
that are uses as the defaults some parmaters used by other ADO CMDLETS


.PARAMETER Context
An ADO Context created using Get-ADOContext.  use the -Excamples swith to view code flow for 
calling Set-ADOGlobals

.PARAMETER debugCmdlets
Parameter contains a boolean used to control debug output for all ADO CMDLEts.  
By setting the global value debugCmdlets to $true before calling a cmdlet will 
turn on ADO Cmdlet specific debug output.

This variable can be toggled from cmdlet usage to cmdlet usage.

.OUTPUTS
Returns the default header hash table for use with other cmdlet calls.

.EXAMPLE 
    $perTok = "<Personal_Access_Token>"

    $Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD" -wikiName "AzureAD"

    $headerhash = Set-Globals -Context $Context -debugCmdlets $true

    Retreive a context object for the Supportability organization, targeting the AzureAD initializg
    the WikiInfo with the AzureAD Wiki and setting up the debug variable for all ADO Cmdlets.

.NOTES
General notes
#>
function Set-ADOGlobals {
    param (
        [Parameter( HelpMessage = "A context object created using Get-ADOContext cmdlet")]
        [ValidateNotNullOrEmpty()]
        [psobject] $Context = $null,
        [Parameter( HelpMessage = "Setup the debug info for the global workspace")]
        [bool]$debugCmdlets = $false
    )
    #
    # Set-Globals requires an ADO Context created using Get-ADOContext
    #
    $retHash = $Context.adoHeaders
    $global:strOrgUri = $Context.OrgUrl
    $global:WikiInfo = $Context.WinkInfo
    $global:gHeaders = $Context.Headers
    $global:DefaultContext = $Context
    [bool]$global:debugCmdlets = $debugCmdlets
    return $retHash
}
function Write-DebugInfo{
    param(
        [string]$debugString,
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        $ForegroundColor = "White"
    )
    if( $global:debugCmdlets -eq $true ){
        Write-Host -ForegroundColor $ForegroundColor $debugstring
    }
}
function Write-DebugObject{
    [CmdletBinding()]
    param (
        [string] $debugString = "Dump Object -> ",
        [Object] $inputObject,
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        $ForegroundColor = "White"
    )
    if( $global:debugCmdlets )
    {
        $outStr = Write-Output $inputObject
        $outStr = [string]::Format("{0}{1}", $debugString, $outStr)
        Write-Host -ForegroundColor $ForegroundColor $outStr
    }
}
