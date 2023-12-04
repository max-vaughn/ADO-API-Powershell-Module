function Remove-Wiki {
    param (
        [string] $wikiUri, 
        [hashtable] $header
    )
    $deleteWikiUri = [string]::Format("{0}?api-version=6.0", $wikiUri)
    Write-DebugInfo $deleteWikiUri -ForegroundColor DarkMagenta
    $results = Invoke-RestMethod -Method Delete -Uri $deleteWikiUri -Headers $header
    return $results 
}