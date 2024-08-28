<#
==================> Function Get-ADORepository <==================
#>
FIX THIS FILE, change all comments and functional information!
NOT READY FOR PRIME TIME!

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
function Get-ADORepository {
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