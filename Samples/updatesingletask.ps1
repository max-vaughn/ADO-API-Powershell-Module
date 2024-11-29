param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'C:\data\beckworkitems_plus_M365_Identity.csv',
    [string] $OutData = 'C:\temp\data\beckworkitemsafterupdate.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
<#
  This script used as a basis for its main input data a version of the CSSI task query page:
  https://dev.azure.com/CSSSI/CSS%20Knowledge%20Management/_queries/query-edit/?tempQueryId=4dee2d4f-db69-43cf-9f68-6888c0e2f99f

  The script runs through a CSV file generated from the query above and updates the TAGs with the YAML 
  tags from the AzsureAD wiki.

#>
$Context = Get-ADOContext -pat $perTok -organization "CSSSI"  -project "CSS Knowledge Management"
#$retItem = New-ADOWorkItemComment -Context $Context -workItemID "42659" -CommentText "Testing Comments" -orgUrl $Context.OrgUrl -project "CSS Knowledge Management"
$TskObjs = Import-Csv -Path $InputData 
$taskCount = $TskObjs.Count
#$item = $TskObjs[2]
#$taglist = $tagstr.SPlit(';')
$count = 0
$ReplaceOp = New-ADOCreateOperation -operation replace -value "Top 10% Usage" -path '/fields/System.Tags'
$updateHistory = @()
foreach ( $item in $TskObjs ) {
    $updateIssue = ""
    $updateAction = ""
    $upitem = $item.PSObject.Copy()
    $operations = @()
    $tagList = ""
    if ( $item.YAMLTags.Length -GT 0 ) {
        $taglist = $item.YAMLTags.Split(';')
    }
    else {
        $tagList = "No YAML Tags"
    }
    #
    # First, remove the old Tags by putting the original tag back.
    #
    $retItem = Update-ADOWorkItem -orgUrl $Context.OrgUrl -project "CSS Knowledge Management" -workItemID $item.ID -operations $ReplaceOp -header $Context.Headers
    if ( $null -eq $retItem ) {
       $updateIssue = "Unable to update task: $taskId"
       $upitem | Add-Member -Name "Status" -Type NoteProperty -Value "Failed to clear Tags"
    }
    else {
        try {
            $updateAction = "adding tags"
            foreach ( $tg in $tagList) {
                $op = New-ADOCreateOperation -operation add -value $tg -path '/fields/System.Tags'
                $taskId = $item.ID
                $retItem = Update-ADOWorkItem -orgUrl $Context.OrgUrl -project "CSS Knowledge Management" -workItemID $item.ID -operations $op -header $Context.Headers
            }
            #
            # Now, add a comment to the task with the additional information
            #
            $updateAction = "adding comments"
            if ( $item.GitItemPath.Length -GT 0 ) {
                $Comment = New-Object System.Text.StringBuilder
                [void]$Comment.AppendLine("Additional AzureADWiki Information<br>")
                [void]$Comment.AppendLine("GitItemPath:<br>")
                [void]$Comment.AppendFormat("<b>{0}</b><br>", $item.GitItemPath)
                [void]$Comment.AppendLine("Wiki Title:<br>")
                [void]$Comment.AppendFormat("<b>{0}</b><br>", $item.WikiTitle)
                $retItem = New-ADOWorkItemComment -Context $Context -workItemID $item.ID -CommentText $Comment.ToString() -orgUrl $Context.OrgUrl -project "CSS Knowledge Management"
            }
        }
        catch {
            $upitem | Add-Member -Name "Status" -Type NoteProperty -Value "Failed in updating $updateAction"
        }
    }
    if( $updateIssue.Length -gt 0 ) { Write-Host $updateIssue }
    Write-Host -NoNewline "`r$count -> $taskCount"
    $updateHistory = $updateHistory + $upItem
    $count++
}
#$retItem = Update-ADOWorkItem -orgUrl $Context.OrgUrl -project "Community - Identity Azure Dev Ops Wiki" -workItemID $taskId -operations $operations -header $Context.Headers
<#
foreach( $tobj in $TskObjs){
    $page = Get-WikiPage -wikiPageFullUrl $tobj.URL -headers $Context.Headers -returnPageObject $true
    $wikiPage = Get-AdoWikiYAMLtags -Context $Context  -wikiPageFullUrl $tobj.URL -recursionLevel oneLevel
    $tobj | Add-Member -Name "YAMLTags" -Type NoteProperty -Value $wikiPage[0].YAMLTags
}

$TskObjs | Export-Csv -Path $OutData -Force 
#>