#
# Get-AdoWikiYAMLtags
#
# ==================> Function Get-YAMLBlock <==================

<# 

.SYNOPSIS
Builds a YAML block from an input string array

.DESCRIPTION
Given an input array of strings, the cmdlet returns an array of strings
representing a YAML block similar to the following:

---
Tags:
- cw.AAD
- cw.AAD-Account-Management
- cw.AAD-Authentication
- cw.AAD-Dev-Boundaries
- cw.AAD-Dev
--- 


.PARAMETER InputTags
An array of strings taking the form:
$tags = @("one","two","three")

If this array is empty, the cmdlet returns an empty string array.

.OUTPUTS
Given an array of strings, the cmdlet outputs an array of strings
representing a YAML tag block similar to the following:
---
Tags:
- cw.AAD
- cw.AAD-Account-Management
- cw.AAD-Authentication
- cw.AAD-Dev-Boundaries
- cw.AAD-Dev
--- 
   
.EXAMPLE 
$tags = @("one","two","three")
$YAMLBlock = Get-YAMLBlock -InputTags $tags

Given a string array $tags, $YAMLBlock will be:
[0] = "---"
[1] = "Tags:""
[2] = "- one"
[3] = "- two"
[4] = "- three"
[5] = "---"


.NOTES
Use this cmdlet to add a YAML Tag block to the content of a wiki 
article

#>
function Get-YAMLBlock {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]] $InputTags = @()
    )
    if( $InputTags.Count -eq 0 ){
        return $InputTags
    }
    $YAMLBlock = @("---", "Tags:")
    foreach($str in $InputTags ){
        $outStr = "- " + $str
        $YAMLBlock = $YAMLBlock + $outStr
    }
    $YAMLBlock = $YAMLBlock + "---"
    return $YAMLBlock
}