#
# Set-ADOGlobals - use this cmdlet if you want to set some defaults for the module.
#   once used, the Global variables:
#      strEncodedPersonalToken - teh encoded personal token retrieved from a web intance of ADO
#      strOrgUri - organization base URI
#
# A hash table is created that can be used as that can be passed to other cmdlets to make it easy to 
# have multiple hashed tokens for different organizations.
#
# ==================> Function Set-ADOGlobals <==================

<# 

.SYNOPSIS
This takes information from the Context parameter and sets default global variables.

.DESCRIPTION
Using the output from the Get-ADOContext cmdlet, this cmdlet sets some global varialbes
that are uses as the defaults some parmaters used by other ADO CMDLETS


.PARAMETER Context
An ADO Context created using Get-ADOContext.  use the -Excamples swith to view code flow for 
calling Set-ADOGlobals

.PARAMETER debugCmdlets
Parameter contains a boolean used to control debug output for all ADO CMDLEts.  
By setting the global value debugCmdlets to $true before calling a cmdlet will 
turn on ADO Cmdlet specific debug output.

This variable can be toggled from cmdlet usage to cmdlet usage.

.OUTPUTS
Returns the default header hash table for use with other cmdlet calls.

.EXAMPLE 
    $perTok = "<Personal_Access_Token>"

    $Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD" -wikiName "AzureAD"

    $headerhash = Set-Globals -Context $Context -debugCmdlets $true

    Retreive a context object for the Supportability organization, targeting the AzureAD initializg
    the WikiInfo with the AzureAD Wiki and setting up the debug variable for all ADO Cmdlets.

.NOTES
General notes
#>
function Set-ADOGlobals {
    param (
        [Parameter( HelpMessage = "A context object created using Get-ADOContext cmdlet")]
        [ValidateNotNullOrEmpty()]
        [psobject] $Context = $null,
        [Parameter( HelpMessage = "Setup the debug info for the global workspace")]
        [bool]$debugCmdlets = $false
    )
    #
    # Set-Globals requires an ADO Context created using Get-ADOContext
    #
    $retHash = $Context.adoHeaders
    $global:strOrgUri = $Context.OrgUrl
    $global:WikiInfo = $Context.WinkInfo
    $global:gHeaders = $Context.Headers
    $global:DefaultContext = $Context
    [bool]$global:debugCmdlets = $debugCmdlets
    return $retHash
}
