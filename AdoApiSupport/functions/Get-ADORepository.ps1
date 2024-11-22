<#
==================> Function Get-ADORepository <==================
#>
FIX THIS FILE, change all comments and functional information!
NOT READY FOR PRIME TIME!

<#
.SYNOPSIS
Retrieves all of the repositories in a given project.
Requires a Personal Access Token represented in the Authorization header value in the 
headers parameter.


.DESCRIPTION
Retrieves the repositories of a given project.
The cmdlet takes a Context object created by Get-ADOContext that contains information about the environment. If
the Context object is missing, the cmdlet will use the provided information in the other parameters. 
Requires a Personal Access Token represented in the Authorization header value in the 
headers parameter.

Implements the ADO API located at:
https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/list?view=azure-devops-rest-7.2&tabs=HTTP

.PARAMETER Context
A context object created by the Get-ADOContext cmdlet

.PARAMETER project
A project name within the specified Context to target the API to retrieve the repositories.

.PARAMETER repositoryID
A target repository, if null, all of the repositories are returned as PSObject types using
the GitRepository type defined:
https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/list?view=azure-devops-rest-7.2&tabs=HTTP#gitrepository

If not Null a PSObject is returned with the single GitRepository type defined at the link above.

the value can be a string representing the ID guid of the repository or the repository name.

.PARAMETER baseUrl
String containing the base URL for the organization.  

.PARAMETER repositryURL
If present, must contain the full url to the target repository.

.PARAMETER projectOrdinal
Interger value representing the index of the target project within the provided Context object.
This parameter is ignored if the Context object is null.

.PARAMETER headers
Contains the headers that should be used to make the Get request.
if headers has a value, it will be used to make the Get request.

.PARAMETER apiVersion
Target API version.  Orignal code was created targeting api version 7.2-preview.1

.OUTPUTS
A target repository, if null, all of the repositories are returned as PSObject types using
the GitRepository type defined:
https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/list?view=azure-devops-rest-7.2&tabs=HTTP#gitrepository

If not Null a PSObject is returned with the single GitRepository type defined at the link above.


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
        [psobject] $Context = $null,
        [int] $projectOrdinal = -1,
        [string] $project = $null,
        [string] $organization = $null,
        [hashtable] $headers = $null,
        [string] $baseUrl = $null,
        [string] $repositoryID = "",
        [string] $query = "",
        [string] $apiVersion = "api-version=7.2-preview.1"
    )
    if( $Null -eq $Context ) {

    }
    <# $requestURL = ""
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
    #>
    return $results
}