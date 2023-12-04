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