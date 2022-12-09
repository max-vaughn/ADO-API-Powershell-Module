# ==================> Function New-ReplacementItem <==================

<# 

.SYNOPSIS
This cmdlet created replacement items that can be used with the New-WorkItemsFromWikiPages

.DESCRIPTION
This cmdlet will create replacement items that can be used withthe New-WorkItemsFromWikiPages to update
description properties of work items with wiki page specific data.

The description replacement process allows the programmer to define tags in the description text and then 
associate a to text.  In the New-WorkItemsFromWikiPages cmdlet, there is logic that will associate the FromTag with a 
specific property in the wiki pages information.  Currently the ID ( page ID ) and the gitItemPath are supported by using the 
syntax item.ID and Item.gitItemPath in the ToValue of the replacement item.


.PARAMETER FromTag
String to search for in the description template, once found, will be replaced with the ToValue

.PARAMETER ToValue
When a FromTag is found, then it is replaced with this value.  The New-WorkItemsFromWikiPages supports two
property tags that are associated with the Wike Page:

Item.ID - the pageID value for the wiki page
Item.gitItemPath - the path to the file in the folder

These properties are described in the following link:
https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get?view=azure-devops-rest-5.0#wikipage

With the adde property ID that contains the page ID value obtained by calling the API:
https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get%20page%20by%20id?view=azure-devops-rest-6.0

And adding the ID value to the wikpage structure for obtaining multiple pages.

.OUTPUTS
PSObject that contains two properties:
   FromTag - tag to find and replace
   ToValue - replacement text for the tag

.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$headers = Set-ADOAuthHeaders -pat $perTok

Creating an array of Replacement items

.EXAMPLE

$LocalTokenHash = @{ token = $global:strEncodedPersonalToken; org = $global:strOrgUri }
$headers = Set-ADOAuthHeaders -tokenHash $localTokenHash

Using an existing tokenHash table create a header struction.
.EXAMPLE 
$perToken = "<Personal_Access_Token>"
$heasers = SetADOAuthHeaders -curHeader $existingHeaders -pat $perToken

Update an existing header structure with a new Personal Access Token

.NOTES
General notes
#>
function new-replacementItem {
    param(
    [string] $FromTag,
    [string] $ToValue
    )
    $retItem = new-object  -TypeName PSObject
    $retItem | Add-Member -Name "FromTag" -Type NoteProperty -Value $FromTag
    $retItem | Add-Member -Name "ToValue" -Type NoteProperty -Value $ToValue
    return $retItem
}

function Get-WorkItemDescription {}

function Write-HTMLliFromPageInfo {
param (
    [PSObject] $pageInfo,
    [string] $wikiUrl
)
$retVal = [System.Text.StringBuilder]::new("")
foreach( $page in $pageInfo){
    $lastSlash = $page.path.LastIndexOf('/')
    $FileName = $page.path.SubString( $lastSlash+1 )
    $pageUrl = [String]::Format("{0}?pageId={1}", $wikiUrl, $page.ID)
    $htmlListItem = [System.Text.StringBuilder]::new("")
    $htmlListItem.AppendFormat("<li><a href=""{0}"" title=""{1}"">{1}</a></li>", $pageUrl, $FileName)
    [void]$retVal.AppendLine( $htmlListItem.ToString())
}
return $retVal.ToString()

}