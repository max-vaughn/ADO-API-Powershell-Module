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