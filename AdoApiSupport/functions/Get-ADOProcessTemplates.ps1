function Get-ADOProcessTemplates {
    param (
        [Parameter()]
        [hashtable]
        $headerProperties,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $orgUrl,
        [ValidateNotNullOrEmpty()]
        [string] $project,
        [string] $Filter
    )
    $processTemplateUrl = [string]::Format("{0}/_apis/work/processadmin?api-version=6.0-preview.1" , $orgUrl)
    Write-DebugInfo -$debugString $processTemplateUrl -ForegroundColor Green
    $results = Invoke-RestMethod -Method Get -Uri $processTemplateUrl -Headers $headerProperties 
    return $results
}