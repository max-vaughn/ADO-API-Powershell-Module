<#
Get-WikiFromContext
 This function returns a WikiInfo takes a Context object returned from the 
 Get-Context cmdlet and returns a specific WikiV2 structure based on the
 input criteria.  

 The WikiV2 object is defined at the following link:
 https://learn.microsoft.com/en-us/rest/api/azure/devops/wiki/wikis/get?view=azure-devops-rest-7.1&tabs=HTTP#wikiv2

#>
function Get-WikiFromContext {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSobject] $context = $null,
        [string] $Name = ""
    )
    if( $null -eq $context ){
        $outErr = [string]::Format("Get-WikiFromContext -context is null -context must be a valid Context object returned from Get-Context.")
        throw $outErr       
    }
    if( $Name.Length -eq 0 ){
        $outErr = [string]::Format("Get-WikiFromContext -Name is empty -Name must be a wiki name.")
        throw $outErr         
    }
    $wikiFound = -1
    for( $i = 0; $i -cle $context.WikiInfo.Value.count; $i++){
        if( $context.WikiInfo.Value[$i].Name -eq $Name ){
            $wikiFound = $i
            break
        }
    }
    if( $wikiFound -gt -1 ) { 
        #
        # Using the WikiV2 documentation definition, create a customer PSObject 
        # that represents a WikiV2 object
        $wikiInfo = new-object psobject
        $wikiInfo = $context.WikiInfo.Value[$wikiFound].psobject.copy()
        return $wikiInfo
    }
    else { return $null   }
}