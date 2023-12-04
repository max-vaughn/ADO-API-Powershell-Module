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