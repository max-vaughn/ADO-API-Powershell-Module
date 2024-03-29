function Remove-Repo {
    param (
        [string] $repoId, 
        [string] $baseUrl,
        [hashtable] $header
    )
    $deleteRepoUri = [string]::Format("{0}_apis/git/repositories/{1}?api-version=7.0", $baseUrl, $repoId)
    Write-DebugInfo $deleteRepoUri -ForegroundColor DarkMagenta
    $results = Invoke-RestMethod -Method DELETE -Uri $deleteRepoUri -Headers $header
    return $results 
}