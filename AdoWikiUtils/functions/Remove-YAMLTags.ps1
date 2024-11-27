#
# Remove-YAMLTags
#
# ==================> Function Remove-YAMLTags <==================

<# 

.SYNOPSIS
Take the wiki article contents and remove the YAML Tag blog, and return a new content buffer.

.DESCRIPTION
Take the contents of a wiki article and strip the YAML tag block

.PARAMETER ContentIn
Content of a wiki article  to start work.

.PARAMETER YAMLTags
YAML Tag list to add to an article, replacing the old YAML list

.PARAMETER AddTags
Boolean, defaults to false to remove tags.  If its true, then the YAMLTags block is added.
If the YAMLTags block is empty, then nothing is done to the wiki article content and
the return value is set to ""

.OUTPUTS
If AddTags is false:
the wiki content in ContentIn is striped of YAML tags and the 
the return value contains the wiki article without tags.

If AddTags is True:
The YAMLTags variable contents replaces the current YAML Tag block in the article
The results is returned
If YAMLTags is empty, then ContentOut will be set to ""
   
.EXAMPLE 
$perTok = "<Personal_Access_Token>"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD" -wikiName "AzureAD"
$item = "https://supportability.visualstudio.com/f3a37cb5-3492-4581-8dbd-f3381f2b1736/_wiki/wikis/cdffcfd7-d961-4bdd-b53b-2759c05108d2?pageID=1285230"
$page = Get-WikiPage -wikiPageFullUrl $item -headers $Context.Headers -includeContent $true
$NewContent = Remove-YAMLTags -ContentIn $page.content 

Retrieve a context object for the Supportability organization, targeting the AzureAD initialize
the WikiInfo with the AzureAD Wiki

Strip the YAML Tag block form a content buffer.
Return the stripped content.

.EXAMPLE
$NewTags = @("cw.New One","cw.New Two")
$perTok = "<Personal_Access_Token>"
$item = "https://supportability.visualstudio.com/f3a37cb5-3492-4581-8dbd-f3381f2b1736/_wiki/wikis/cdffcfd7-d961-4bdd-b53b-2759c05108d2?pageID=1285230"
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD" -wikiName "AzureAD"
$resItem = Get-WikiPage -wikiPageFullUrl $item -headers $Context.Headers -includeContent $true
$NewContent = Remove-YAMLTags -ContentIn $page.content -YAMLTags $NewTags -AddTags $true

Retrieve a context object for the Supportability organization, targeting the AzureAD initialize
the WikiInfo with the AzureAD Wiki

Get the wiki article content and add the list of new tags defined in $NewTags, replacing
the current YAML Tab block if it exists.

.NOTES
Using this cmdlet, the programmer can build multiple context objects for use in a single script.

For example, an AzureAD Wiki context can be used to create a list of articles.  This list of articles can then 
be used to build a series of ADO work items in another project.

For an example of a cmdlet that does just this type of work, see the New-WorkItemsFromWikiPages 
Get-help New-WorkItemsFromWikiPages 

#>
function Remove-YAMLTags {
    param (
        [Parameter()]
        [string] $ContentIn = "",
        [string[]] $YAMLTags = @(),
        [bool]$AddTags = $false
    )
    [string]$NewContent = ""
    [string]$OutContent = ""
    if ($ContentIn.Length -eq 0) {
        return $NewContent
    }

    $srl = New-Object System.IO.StringReader -ArgumentList $ContentIn
    if ($ContentIn.IndexOf("---", 0, 6) -gt -1) {
        $srLine = $srl.ReadLine()
        $YAMLBlock = ""
        $firstItem = $true
        while ($true) {
            $srLine = $srl.ReadLine()
            if ($null -eq $srLine) { break }
            if ($srLine.IndexOf("---") -gt -1) { break }
            if ($srLine.IndexOf("Tag") -eq -1) {
                $srLine = $srLine.Replace("- ", "")
                if (-not [string]::IsNullOrWhiteSpace($srLine)) {
                    if ($firstItem) { 
                        $YAMLBlock = $srLine
                        $firstItem = $false
                    } else { 
                        $YAMLBlock = $YAMLBlock + ";" + $srLine 
                    }
                }
            }
        }
    }

    if ($AddTags -eq $true -and $YAMLTags.Count -gt 0) {
        $NewTags = Get-YAMLBlock -InputTags $YAMLTags
        foreach ($tag in $NewTags) {
            $OutContent = $OutContent + $tag + "`n"
        }
    }

    while ($true) {
        $srLine = $srl.ReadLine()
        if ($srLine -eq $null) { break }
        $OutContent = $OutContent + $srLine + "`n"
    }

    $NewContent = $OutContent.ToString()
    return $OutContent
}
