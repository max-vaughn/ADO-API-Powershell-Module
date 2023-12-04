# ==================> Function Update-WikiPage <==================

<# 
.SYNOPSIS
Updates a wiki article content by using the ETag returned in the repsonse headers when
The wiki article was retrieved.  An ETag is necessary to update an article successfully.  The 
easist way to obetain an ETag for the article is to use the Get-WikiPage cmdlet passing new PSObject
in the -ReturnHeaders parameter.


.DESCRIPTION
Based on the ADO Wiki Page update APIs:
https://learn.microsoft.com/en-us/rest/api/azure/devops/wiki/wikis/update?view=azure-devops-rest-7.0&tabs=HTTP

Will replace the current content of an article with the content provided in the -Content parameter.

The cmdlet requires the following:
1. A token or a Context object returned from Get-ADOContext and a pageID
2. A PageID for a wiki article and a Context object to target the a specific wiki
3. A PageID and a Wiki URL that points to the wiki along with a token
4. A full wiki page URL with a Token
5. A full wiki page URL with a Context object returned from Get-ADOContext
And
Some content to replace the current content and an ETag value for the article, or the cmdlet will throw an exception.



EXAMPLES
# Need Examples

.PARAMETER adoContext
a PSObject returned by the Get-ADOContext cmdlet.
If no value is provided, the parameter is defaulted to NULL

.PARAMETER ETag
The ETag is a string array returned by a previous Get-WikiPage cmdlet in the Response 
headers.  The ETag is used to identify which version of the article to update in the
Wiki repository.

.PARAMETER wikiOrdinal
Index to use in the ADO Context objects WikiInfo array.  This ordinal
identifies which wiki information structure to use to obtain the base wiki
url.  The value is defaulted to 0.

.PARAMETER wikiPageFullUrl
This is the full wiki URL to use to update the article.  


.PARAMETER workUri
The base wiki uri that is used to build the final wiki article path.  If this 
value is empty and the Context object is empty and the wikiFullUrl is empty, then
the CMDLET cannot identify the article to modify and will throw an 
Exception.

.PARAMETER PageID
This is the page ID of the wiki article, can be used to build the full wiki URL from 
the other component parts of the URL.  This value is required if the wikiPageFullUrl is
empty.

.PARAMETER headers
Hashtable containing the HTTP headers to send with the REST request.  Must inlcucde the authentication header value build from the Personal Access Token

.PARAMETER apiVersion
Full version parameter string, currently, it is defaulted to api-version=7.2-preview.1" but can be
changed to target others.

.PARAMETER Content
The content for the article.  If no content is passed the cmdlet will throw an execption.  
Nothing to update.

.NOTES
General notes
#>
function Update-WikiPage  {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSObject] $adoContext = $null,
        $ETag = $null,
        [int] $wikiOrdinal = 0,
        [string]  $wikiUri = "",
        [string]  $wikiPageFullUrl = "",
        [string]  $pageId = "",
        [ValidateNotNull()]
        [hashtable] $headers = $global:gHeaders,
        [string] $apiVersion = "api-version=7.2-preview.1",
        [string]$Content = ""
    )
    #
    # Setup debug stringbuilder
    #
    
    #
    # Check the Content parameter.
    # If its not set, there is nothing to do, exit
    #
    if( $Content.Length -eq 0 ){
        return $null
    }
    #
    # Next, 
    # If the target wiki full page URL is provided, use it without question
    # may add checks later to make sure its the correct endpoint.
    #  
    $wikiPage = ""
    $callHeaders = $headers
    if( $wikiPageFullUrl.Length -gt 0 ){
        $wikiPage = [string]::Format("{0}?&{1}", $wikiPageFullUrl, $apiVersion)
    }
    elseIf (( $null -eq $adoContext) ){
        if ( $wikiUri.Length -eq 0 ) {
            if ( $wikiPageFullUrl.Length -eq 0 ) {
                #
                # Either the ADO Context returned by Get-ADOContext 
                # or the wiki base URI 
                # or a full wiki page url must be present
                #
                $outErr = [string]::Format("Update-WikiPage - Missing adoContext, wikiUri and wikiPageFullUrl. Must have one of these values")
                throw $outErr
            }
        }
    } 
    #
    # If the target wiki page url ( wikiPage vairable) has 0 length,
    # we need to build the full page url based on the adoContext, pageID
    # and possibly the wikiUri
    # 
    if ( $wikiPage.Length -eq 0 ) {
        if( $pageId.Length -eq 0 ){
            # 
            # at this piont, must have a wiki page ID value
            # Throw an exception and exit
            #
            $outErr = [string]::Format("Update-WikiPage - No pageId provided.  CMDLET is designed update content on a page, must have a pageId")
            throw $outErr
        }
        If ( $null -eq $Content ) {
            #
            # Build the URI based on the $wikiUri, the $pageId and the $apiVersion
            #
            if( $wikiUri.Length -eq 0 ){
                #
                # We have a pageId,
                # Now, not using the Context so we need a wikiUri to build the path.
                # if the wikiUri is empty, then we throw an exception
                # 
                $outErr = [string]::Format("Update-WikiPage - No context object and no target wiki uri provided.  Must have on or the other.")
                throw $outErr
            }
            $wikiPage = [string]::Format("{0}/pages/{1}?&{2}", $wikiUri, $pageId, $apiVersion)
        }
        else{
            #
            # We are defaulting to the context object, using the wiki url from the WikiInfo object
            # and the provided pageId
            #
            $wikiPage = [string]::Format("{0}/pages/{1}?&{2}",$adoContext.WikiInfo.value[$wikiOrdinal].url, $pageId, $apiVersion)
            $callHeaders = $adoContext.Headers
           if( $ETag.Length -gt 0 ){
                #
                # we have a possible version value, add the appropriate header
                #
                $callHeaders.Add( "If-Match", $ETag)
                $outStr = write-output $ETag
                
                Write-DebugInfo $outStr DarkRed
            }
        }
        #
        # At this point, we have a wiki page to target
        #
    }
    #
    # Debug information
    #
    $dbgString = [string]::Format("Update-WikiPage -> {0}", $wikiPage)
    Write-DebugInfo -ForegroundColor DarkCyan $dbgString
    #
    # 
    # Build the body of post call
    #
    $body = "{
          `"Content`": `"$Content`"
        }"
    $results = Invoke-RestMethod -Method PATCH -Uri $wikiPage -Headers $callHeaders -ResponseHeadersVariable resHeaders -Body $body -ContentType "application/json"
    $outStr = write-output $results
    $dbgString = [string]::Format("Update-WikiPage -> Results:{0}", $outStr)
    Write-DebugInfo $dbgString -ForegroundColor DarkYellow
    return $results
}