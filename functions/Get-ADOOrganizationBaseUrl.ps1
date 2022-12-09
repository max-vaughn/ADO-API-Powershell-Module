<#
==================> Function Get-ADOOrganizationBaseURL <==================
#>


<#
.SYNOPSIS
Retrieves an organization's base URL that can be used to objectain additional information from
an organziation using APIs.  The cmdlet does not require any special permissions to execute.


.DESCRIPTION
Retrieves the base url for an organization that can be used to build other URLs to
obtain additional data from Azure Dev Ops using the APIs.

Implements the ADO API located at:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#how-to-get-an-organizations-url

Using the core area ID defined in the following link
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#resource-area-ids-reference


.PARAMETER organizationName
The organizationName is a required parameter, it cannot be null.  This value is used to lookup the 
core URL structure defined here:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#how-to-get-an-organizations-url

.Parameter returnBaseUrl
This boolean parameter can be used to return just the locationUrl of organization.  
THe parameter defaults to True.

.PARAMETER apiVersion 
This parameter is present to allow for different versions of an API to be called.
The parameter is initialed to the current API version as of 01/12/2021 to successfully 
execute the target API.

.EXAMPLE
$orgUrls = Get-ADOOrganizationBaseUrl -organization "IdentityCommunities" -returnBaseUrl $false
$orgUrls


id                                   name locationUrl
--                                   ---- -----------
79134c72-4a58-4b42-976c-04e7115f32bf core https://dev.azure.com/IdentityCommunities/

Return the entire core URL strusture including the area ID and the base url

.EXAMPLE
$orgBaseUrl = Get-ADOOrganizationBaseUrl -organization "IdentitiesCommunities"
$orgBaseUrl

https://dev.azure.com/IdentityCommunities/

Return just the base url for the organization

.NOTES
General notes
#>
function Get-ADOOrganizationBaseURL
{
    [CmdletBinding()]
    param (
        [string]  $organizationName,
        [bool] $returnBaseUrl = $true,
        [string] $apiVersion = "api-version=5.0-preview.1"
    )
    $requestURL = [string]::Format("https://dev.azure.com/_apis/resourceAreas/79134C72-4A58-4B42-976C-04E7115F32BF?accountName={0}&{1}",$organizationName, $apiVersion)
    $result = Invoke-RestMethod -Method GET -uri $requestURL
    if( $returnBaseUrl ){
        $retVal = $result.locationUrl
    }
    else {
        $retVal = $result
    }
    return $retVal
}