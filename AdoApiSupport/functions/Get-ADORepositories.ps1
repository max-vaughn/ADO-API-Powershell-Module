# ==================> Function Get-ADORepos <==================

<# 

.SYNOPSIS
Using a Personal Access Token and an organization, this cmdlet created a context object for the pat.

.DESCRIPTION
Using a Personal Access Token  and an organization the cmdlet builds a context object for the PAT.

Information about Personal Access Tokens can be found at this link:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

See Outputs for details on the Context object that is returned by this cmdlet.


.PARAMETER pat
Personal Access Token obtained from Azure Dev Ops, see the following link for details on PATs:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

If this parameter is present, it will be used to create the header hashtable.

Either the pat or the tokenHash must have a valure in order to execute this cmdlet.

.PARAMETER organization
parameter contains the target organization that is associated with the pat parameter.
This parameter cannot be null, it must contain an organization name.

.PARAMETER project
parameter represents a target project used to initialize the context object.

.OUTPUTS
The cmdlet outputs a PSCustomObject refered to as the Context object.  
The properties of the contects object are:

   WikiInfo      - Information about any wiki's that the context may contain.  IF a wikiName is provided
                   structure is information about that specific wiki.
    Headers      - Hash table that represents the headers structure for the PAT.  Contains
                   the Authorization Header value with the encoded PAT.
    OrgUrl       - The organization URL used for building API calls including the trailing /
    Project      - Contains the project name used to acquire the ProjectID property of the context.
    ProjectId    - Contains the unique identifier for the project.  Used in building API urls
    Organization - Oganization name for this context.
    Projects     - Collection of projects for the given organization
   
.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"

Retrieve a context object for the Supportability organization, targeting the AzureAD project

.EXAMPLE
$perTok = "<Personal_Access_Token>"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD" -wikiName "AzureAD"

Retreive a context object for the Supportability organization, targeting the AzureAD initializg
the WikiInfo with the AzureAD Wiki

.NOTES
Using this cmdlet, the programmer can build multiple context objects for use in a single script.

For example, an AzureAD Wiki context can be used to create a list of articles.  This list of articles can then 
be used to build a series of ADO work items in another project.

For an example of a cmdlet that does just this type of work, see the New-WorkItemsFromWikiPages 
Get-help New-WorkItemsFromWikiPages 

#>
function Get-ADORepos {
    param (
        [psobject] $Context = $null, 
        [string] $baseUrl,
        [string] $repoID = $null,
        [hashtable] $header = $global:gHeaders
    )
    $deleteRepoUri = [string]::Format("{0}_apis/git/repositories/{1}?api-version=6.0", $baseUrl, $repoId)
    Write-DebugInfo $deleteRepoUri -ForegroundColor DarkMagenta
    $results = Invoke-RestMethod -Method Delete -Uri $deleteRepoUri -Headers $header
    return $results 
}