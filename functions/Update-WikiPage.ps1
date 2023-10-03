
function Update-WikiPage  {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSObject] $adoContext = $null,
        [string] $ETag = "",
        [int] $wikiOrdinal = 0,
        [string]  $wikiUri = "",
        [string]  $wikiPageFullUrl = "",
        [string]  $pageId = "",
        [ValidateNotNull()]
        [hashtable] $headers = $global:gHeaders,
        [string] $apiVersion = "api-version=7.2-preview.1",
        [string]$Content = "",
        [string] $pageVersion = ""
    )
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
    $results = Invoke-RestMethod -Method PUT -Uri $wikiPage -Headers $callHeaders -ResponseHeadersVariable resHeaders
    $outStr = write-output $results
    $dbgString = [string]::Format("Update-WikiPage -> Results:{0}", $outStr)
    Write-DebugInfo $dbgString -ForegroundColor DarkYellow
    return $results
}