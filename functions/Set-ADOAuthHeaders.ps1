# ==================> Function Set-ADOAuthHeaders <==================

<# 

.SYNOPSIS
This cmdlet creates a header hashtable that can be used with an Invoke-RestMethod request
and provides at a minimum, the Authorization header value.

.DESCRIPTION
Using a Personal Access Token or a hashtable that contains the encoded access token, 
the cmdlet will create a hashtable that contains header values that can be used with
an Invoke-ResthMothod which executes an Azure Dev Ops API.

Information about Personal Access Tokens can be found at this link:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page


.PARAMETER pat
Personal Access Token obtained from Azure Dev Ops, see the following link for details on PATs:
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

If this parameter is present, it will be used to create the header hashtable.

Either the pat or the tokenHash must have a valure in order to execute this cmdlet.

.PARAMETER curHeader
Parameter that contains the current header values.  If present, either the encoded pat paramer or the tokenhash parameter will 
be used to fill the Authorization header value for the returned hash table.  This is a way to use an existing set of 
header values and just replace the Authorization portion of the header values.

.PARAMETER header
Hashtable containing the headers that will be added to the Invoke-RestMethod cmdlet.  The header must 
contain the Authorization header value.  Use the Set-ADOAuthHeaders cmdlet with a Personal Access Token to 
create a header hashtable.

.OUTPUTS
Hashtable for the Authentication header value:
$header = @{Authorization = "Basic " + $localHash.token }
.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$headers = Set-ADOAuthHeaders -pat $perTok

Using a personal access token, create a header structure

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
function Set-ADOAuthHeaders {
    [CmdletBinding()]
    param (
        [string] $pat = $null,
        [hashtable] $tokenHash = $null,
        [hashtable] $curHeader
    )
    $localHash = $null
    if( $null -ne $pat )
    {
        #
        # We have a PAT, lets endcode it and put it into a token hashtable
        #
        $encodedPat = [System.Convert]::ToBase64String( [System.Text.Encoding]::ASCII.GetBytes(":$global:strPersonalToken"))
        $localHash = @{ token = $encodedPat; org = "" }

    }
    if( $null -ne $tokenHash )
    {
        #
        # There is an existing token hash to use.  Use it
        #
        $localHash = $tokenHash
    }
    if( $null -ne $locaHash )
    {
        #
        # There is no PAT or Token Hash, this is a problem.  One or the other must be present.
        # Throw an exception.
        #
        $outStr = [string]::Format("Must have a Personal Access Token ( pat parameter ) or a TokenHash that contains the encoded PAT ( tokenHash ) both are NULL")
        throw $outStr
    }
    if ( $null -ne $curHeader.Authorization ) {
        $curHeader.Authorization = "Basic " + $localHash.token
        $header = $curHeader
    }
    else {
        $header = @{Authorization = "Basic " + $localHash.token }
    }
    Write-DebugInfo $header.Authorization -ForegroundColor DarkYellow
    return $header

}