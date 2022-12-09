function Write-DebugInfo{
    param(
        [string]$debugString,
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        $ForegroundColor = "White"
    )
    if( $global:debugCmdlets -eq $true ){
        Write-Host -ForegroundColor $ForegroundColor $debugstring
    }
}