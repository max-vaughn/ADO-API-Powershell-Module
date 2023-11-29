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
        [string] $apiVersion = "api-version=7.1",
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
                    $pathval = Get-pagePath -remoteUrl $_.remoteUrl
                    $wikiPage = [string]::Format("{0}/pages/?{1}",$pathVal , $wikiUri,  $recursionLevel, $includeContent.ToString(), $apiVersion)
                    $resPage = Get-WikiPage -wikiPageFullUrl $wikiPage -headers $headers
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
                   $pathval = Get-pagePath -remoteUrl $_.remoteUrl
                   $wikiPage = [string]::Format("{0}/pages/?{1}", $wikiUri, $pathVal )
                  $resPage = Get-WikiPage -wikiPageFullUrl $wikiPage -headers $headers
                   $val = $_
                   $val | Add-Member -Name "ID" -Type NoteProperty -Value $resPage.ID
                   $val
               }
               else {
                   #
                   # Return just the URL
                   #
                   $pathval = Get-pagePath -remoteUrl $_.remoteUrl
                   $wikiPage = [string]::Format("{0}/pages/?{1}", $wikiUri, $pathVal )
                  $wikiPage
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
                #$wikiPage = [string]::Format("{0}/pages/{1}?recursionLevel={2}&includeContent={3}&{4}", $wikiUri, $_.pageId)               
                Get-WikiFolderDocs -wikiUri $wikiUri -wikiPageFullUrl $_.url -headers $headers -apiVersion $apiVersion -returnPageInfo $returnPageInfo
            }
            else {

                if ( $returnPageInfo -eq $true ) {
                    #
                    # Return the entire page information object from the Get on the wiki page
                    #
                    $pathval = Get-pagePath -remoteUrl $_.remoteUrl
                    $wikiPage = [string]::Format("{0}/pages/?{1}", $wikiUri,$pathVal )
                   $resPage = Get-WikiPage -wikiPageFullUrl $wikiPage -headers $headers
                    $val = $_
                    $val | Add-Member -Name "ID" -Type NoteProperty -Value $resPage.ID
                    $val
                }
                else {
                    #
                    # Return just the URL
                    #
                    $pathval = Get-pagePath -remoteUrl $_.remoteUrl
                    $wikiPage = [string]::Format("{0}/pages/?{1}",$wikiUri, $pathVal )
                   $wikiPage
                } # end recursion if block
            } # end checking for onelevel block
        }
    } # end of ForEach-Object block
}