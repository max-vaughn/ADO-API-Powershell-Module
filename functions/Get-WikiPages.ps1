#
# Get-WikiPages
#
# ==================> Function Get-WikiPages <==================

<# 

.SYNOPSIS
Using a Personal Access Token and informaiton about a target wiki, this cmdlet returns pages that match a specific path.

.DESCRIPTION
Using a Personal Access Token  and organization information in conjunction with a path,
this cmdlet will return one page or multiple pages.

Information about Personal Access Tokens can be found at this link:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

See Outputs for details on the Context object that is returned by this cmdlet.


.PARAMETER pat
Personal Access Token obtained from Azure Dev Ops, see the following link for details on PATs:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

If this parameter is present, it will be used to create the header hashtable.

Either the pat or the tokenHash must have a valure in order to execute this cmdlet.

.PARAMETER Context
Context is an object that is returned using the Get-Context cmdlet.  
this object contains information about the projects, wikis and work items contained in a 
specific organization.  for details on the context object, use Get-Help Get-Context -full

.PARAMETER wikiOrdinal
Index into the WikiInfo array contained in the Context objects.  This provides direct access
to the wikis URL and other wiki information.  For detials on the contents of the WikiInfo object see
https://learn.microsoft.com/en-us/rest/api/azure/devops/wiki/wikis/list?view=azure-devops-rest-7.0&tabs=HTTP


.PARAMETER wikiUri
parameter contains url for the base wiki uri, everything except the article and path specifics.  Combined
with the recursionLevel, basePath, apiVersion, and includeContent to build the full REST request.

.PARAMETER wikiPageFullUrl
parameter containing the full wiki article URL, will be combined with the apiVersion, includeContent
parameters to build the full REST request.

.PARAMETER headers
hashtable that allows for the passing of the authentication and other required header valaues in the
form of a hashtable.  

If a Context object is passed and the useContextHeaders is true, then this value is 
ignored.  

If the context object is passed and the useContextHeaders is false, then this value is used as the headers.

.PARAMETER useContextHeaders
boolean value that instructs the cmdlet to use the Context header values.

.PARAMETER accept
if this paramater is not null, then the accept header is added to the headers values.
The string passed to in the accept parameter is used as it is sent to the cmdlet. 
No parameter verification or validation is performed at this time.

.PARAMETER basePath
this paramater should contain a path string that takes the form:
path=[WIKI_ARTICLE_PATH]

for example, if the path to the article is "/mypath/mydir/myfile.md"  then the path string would be
path=/mypath/mydir/myfile.md

.PARAMETER recursionLevel
this parameter represent the recursion level for the request.  
the parameter is constrained to the following:
 [ValidateSet( "none", "oneLevel", "full", "oneLevelPlusNestedEmptyFolders")]

 For information on what the specific values represent, see this link:
 https://learn.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get-page?view=azure-devops-rest-7.0&tabs=HTTP#versioncontrolrecursiontype

 .PARAMETER apiVersion
 this parameter allows for multiple versions of the API to be used.
 Simple set the apiVersion string to the desired version and an attempt to use the
 specified version of the ADO wiki APIs will be made.

.PARAMETER includeContent
includeContent specifies if the content of the article should be included in the 
response.  

This parameter can be used in conjunction with the accept parameter to request
content of a specific type.

NOTE: some API calls will ignore this parameter and will not return any content.

.OUTPUTS
The cmdlet outputs either a single JSON object or an array of objects based on the 
results from this API:
https://learn.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get-page?view=azure-devops-rest-7.0&tabs=HTTP

The JSON returned is described here:
https://learn.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get-page?view=azure-devops-rest-7.0&tabs=HTTP#wikipage
   
.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$page = Get-WikiPages -Context $Context -useContextheaders $true -basePath 'GeneralPages/AAD/AAD Account Management' -includeContent $true

Retrieve a context object for the Supportability organization, targeting the AzureAD project
Return a page including its content in the $page variable using the Context value returned
by the Get-ADOContext cmdlet.

.EXAMPLE
$perTok = "<Personal_Access_Token>"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD" -wikiName "AzureAD"
$pages = Get-WikiPages -Context $Context -useContextheaders $true -basePath 'GeneralPages/AAD/AAD Account Management' -includeContent $true -recursionLevel "oneLevel"

Retreive a context object for the Supportability organization, targeting the AzureAD initializg
the WikiInfo with the AzureAD Wiki

the pages collection will contain all the pages at one level.  To check for additional pages, the subpages collection will 
will contain additional page data.

.NOTES
Using this cmdlet, the programmer can build multiple context objects for use in a single script.

For example, an AzureAD Wiki context can be used to create a list of articles.  This list of articles can then 
be used to build a series of ADO work items in another project.

For an example of a cmdlet that does just this type of work, see the New-WorkItemsFromWikiPages 
Get-help New-WorkItemsFromWikiPages 

#>
function Get-WikiPages {
    [CmdletBinding()]
    param (
        [Parameter()]
        [psobject] $Context = $null,
        [int] $wikiOrdinal = 0,
        [bool] $useContextHeaders = $false,
        [string]  $wikiUri = "",
        [string]  $wikiPageFullUrl = "",
        [hashtable] $headers,
        [string] $accept = "",
        [string] $basePath = "",
        [ValidateSet( "none", "oneLevel", "full", "oneLevelPlusNestedEmptyFolders")]
        [string] $recursionLevel = "none",
        [string] $apiVersion = "api-version=6.0-preview.1",
        [bool]$includeContent = $false
    )
    [hashtable] $tmp_headers;
    $outErr = ""
    <#
      Check the basepath and the wikiPageFullUrl, one of these must have a value.
      If wikiPageFullUrl is not set, then basePath must have a value.
    #>
    if( ($basePath.Length -eq 0) -and ($wikiPageFullUrl.Length -eq 0) ){
        $outErr = [string]::Format("Get-WikiPages -basePath is null and wikiPageFullUrl does not have a value.  One of them must have a value.")
        throw $outErr
    }
    <#
    If wikiPageFullUrl has a value, then use it to build the wikiPages url for the get request
    #>
    if ( $wikiPageFullUrl.Length -gt 0 ) {
        $wikiPages = [string]::Format("{0}?recursionLevel={1}&includeContent={2}&{3}", $wikiPageFullUrl, $recursionLevel, $includeContent.ToString(), $apiVersion)
        $wikiPages = $wikiPageFullUrl
    }
    <#
      Setup the headers for the rest call.
      If the Context has a value, and useContextHeaders is true, then
      use the information in the Context object to initialize the headers for
      the REST call and use the base wikiUrl from the Context object.
    #>
    if( ($Context -ne $null) -and ($useContextHeaders -eq $true) )
    {
       $tmp_headers = $Context.Headers
       $wikiUri = $Context.WikiInfo.Value[$wikiOrdinal].url
    }
    elseif ( $Context -ne $null )
    {
        $tmp_headers = $headers
        $wikiUri = $Context.WikiInfo.Value[$wikiOrdinal].url
    }
    <#
    Check the accept parameter, if it has a value, then add the 
    Accept value to the headers.
    #>
    if( $accept.Length -gt 0 ){
        $tmp_headers.Add("Accept", $accept)
    }
    else {
        $wikiPages = [string]::Format("{0}/pages?path={1}&recursionLevel={2}&includeContent={3}&{4}", $wikiUri, $basePath, $recursionLevel, $includeContent.ToString(), $apiVersion)
        Write-DebugInfo -ForegroundColor DarkRed $wikiPages
    }
    $results = Invoke-RestMethod -Uri $wikiPages -Headers $tmp_headers -ResponseHeadersVariable retHeaders
    Write-DebugInfo -ForegroundColor DarkRed $retHeaders
    Write-DebugObject -ForegroundColor DarkYellow $retHeaders -debugString "Return Headers"
    $Global:RetHeaders = $retHeaders
    return $results
}