function Get-pagePath {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]  $remoteUrl = ""
    )
    if( $remoteUrl.Length -eq 0 ){
        #
        # Must have a string
        #
        $outErr = [string]::Format("Get-pagePath - remoteUrl must have a value cannot be empty")
        throw $outErr
    }
    $path = ""
    $pathStart = $remoteUrl.LastIndexOf( "pagePath=", $remoteUrl.Length, ($remoteUrl.Length - 1))
    if( $pathStart -gt 0 ){
        $Path = $remoteUrl.Substring( $PathStart + 4)
    }
    return $path
 }