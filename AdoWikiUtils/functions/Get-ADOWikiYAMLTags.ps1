#
# Get-AdoWikiYAMLtags
#
# ==================> Function Get-AdoWikiYAMLtags <==================

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
function Get-AdoWikiYAMLtags {
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
    if( $null -eq $Context){
        $local_headers = $headers
    }
    else {
        $local_headers = $Context.Headers
    }
    $articleList = Get-WikiFolderDocs -wikiUri $wikiUri -wikiPageFullUrl $wikiPageFullUrl -pageId $pageId -headers $local_headers -basePath $basePath -recursionLevel $recursionLevel -apiVersion $apiVersion -includeContent $includeContent
    Write-DebugInfo -ForegroundColor DarkCyan "Get-WikiPageList -> + "$articleList.Count
    $wikiPageList = @()
    foreach ($item in $articleList) {
        $resItem = Get-WikiPage -wikiPageFullUrl $item -headers $local_headers -includeContent $true
        #
        # Build PageId reference URL and add it to the output
        #
        $pageUrl = $resItem.remoteUrl
        $lastSlash = $pageUrl.LastIndexOf("/")
        $pageUrl = $pageUrl.SubString(0, $lastSlash)
        $pageUrl = [string]::Format("{0}?pageID={1}", $pageUrl, $resItem.id)
        #
        # Check for YAML tag block, if its present, copy it and return it
        #
        $YAMLBlock = ""
        if( $resItem.content.IndexOf("---", 0, 6) -gt -1 ) {
            #
            # Start block fo YAML tags
            # Find the ending "---" and return all that is inbetween
            #
            $endContent = $resItem.content.Length - 5
            $endYAMLblock = $resItem.content.IndexOf( "---", 4, $endContent)
            if( $endYAMLblock -gt -1 ){
                $YAMLBlock = $resItem.content.SubString(5, $endYAMLBlock-1 )
                $YAMLBlock = $YAMLBlock.Replace("`r`n", ";")
            }
            else {
                $YAMLBlock = ""
            }
        }
        #
        # Create the return item object
        #
        $retItem = new-object PSObject
        $retItem | Add-Member -Name "pageID" -Type NoteProperty -Value $resItem.id
        $retItem | Add-Member -Name "pageUrl" -Type NoteProperty -Value $pageUrl
        $retItem | Add-Member -Name "path" -Type NoteProperty -Value $resItem.path
        $retItem | Add-Member -Name "url" -Type NoteProperty -Value $resItem.url
        $retItem | Add-Member -Name "gitItemPath" -Type NoteProperty -Value $resItem.gitItemPath
        $retItem | Add-Member -Name "Tags" -Type NoteProperty -Value $YAMLBlock
        $retItem | Add-Member -Name "Reviewer" -Type NoteProperty -Value ""
        $retItem | Add-Member -Name "Review Date" -Type NoteProperty -Value ""
        #
        # Stuff it into the list
        #
        $wikiPageList = $wikiPageList + $retItem 
    }
    return $wikiPageList
}
