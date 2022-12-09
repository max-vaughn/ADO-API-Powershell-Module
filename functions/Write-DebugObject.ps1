function Write-DebugObject{
    [CmdletBinding()]
    param (
        [string] $debugString = "Dump Object -> ",
        [Object] $inputObject,
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        $ForegroundColor = "White"
    )
    if( $global:debugCmdlets )
    {
        $outStr = Write-Output $inputObject
        $outStr = [string]::Format("{0}{1}", $debugString, $outStr)
        Write-Host -ForegroundColor $ForegroundColor $outStr
    }
}