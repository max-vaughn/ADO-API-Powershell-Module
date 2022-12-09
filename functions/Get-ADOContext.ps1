# ==================> Function Get-ADOContext <==================

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
function Get-ADOContext {
    [CmdletBinding()]
    param (
        [string]$pat,
        [string]$organization,
        [string]$project,
        [string]$wikiName = $null
    )
    #
    # encode the Personal Access Token and create the header hash table
    #
    if($pat.Length -EQ 0 ){
        $outErr = [string]::Format("Get-ADOContext - Personal Access token cannot be null.  Please provide a personal access token")
        throw $outErr
    }
    if( $null -eq $organization)
    {
       $outErr = [string]::Format("Get-ADOContext - organization cannot be null.  Please provide an organization that is associated with the pat")
       throw $outErr
    }
    $perTok = $pat
    $perTok = [System.Convert]::ToBase64String( [System.Text.Encoding]::ASCII.GetBytes(":$pat"))
    $retHash = @{ token = $perTok; org = $orgUrl }
    $adoHeaders = Set-ADOAuthHeaders -tokenHash $retHash
    $res = Get-ADOOrganizationBaseURL -organizationName $organization
    $orgUrl = $res
    $dbgStr = [string]::Format("Get-ADOContext -> *orgUrl :{0}*-*organization: {1}*-*project: {2}*", $orgUrl, $organization, $project )
    Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
    $projs = Get-ADOProjects -organization $organization -headers $adoHeaders
    $projID = Get-ADOProjectID -projects $projs -project $project
    $dbgStr = [string]::Format("Get-ADOContext -> *project:{0}*-*projID: {1}*", $project, $projID )
    Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
    If( $wikiName.Length -gt 0 )
    {
        #
        # There is a specific wiki name for the wikiInfo structure, use it.
        #
        $WikiInfo =  Get-Wikis -baseUrl $orgUrl -Project $projID -wikiName $wikiName -headers $adoHeaders -Organization $organization
    }
    else {
        # 
        # No specific wiki, get all registered wikis
        #
        $WikiInfo = Get-Wikis -baseUrl $orgUrl -organization $organization -project $projID -headers $adoHeaders
        Write-DebugObject -debugString "Get-ADOContext" -inputObject $WikiInfo
    }
    $retContext = New-Object -TypeName PSObject
    $retContext | Add-Member -Name "WikiInfo" -Type NoteProperty -Value $WikiInfo
    $retContext | Add-Member -Name "Headers" -Type NoteProperty -Value $adoHeaders
    $retContext | Add-Member -Name "OrgUrl" -Type NoteProperty -Value $orgUrl
    $retContext | Add-Member -Name "Project" -Type NoteProperty -Value $project
    $retContext | Add-Member -Name "ProjectId" -Type NoteProperty -Value $projID
    $retContext | Add-Member -Name "Organization" -Type NoteProperty -Value $organization
    $retContext | Add-Member -Name "Projects" -Type NoteProperty -Value $projs
    return $retContext
}