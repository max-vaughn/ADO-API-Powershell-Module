function Get-ADOOperationJSON {
    [CmdletBinding()]
    param (
        [Parameter()]
        $operations
    )
    $outJSON = ""
    if ($operations.count -gt 0 ) {
        #
        # its an array of values, build an array of items to return.
        #
        $strBld = [System.Text.StringBuilder]::new("[")
        [void]$strBld.AppendLine()
        $loopCount = 0;
        foreach ( $item in $operations) {
            #
            # Loop through the operations and build the JSON
            #
            [void]$strBld.AppendLine("   {")
            [void]$strBld.AppendFormat("        ""op"": ""{0}"",", $item.op)
            [void]$strBld.AppendLine()
            [void]$strBld.AppendFormat("        ""path"": ""{0}"",", $item.path)
            [void]$strBld.AppendLine()
            if($item.from.length -gt 0 ){
                [void]$strBld.AppendFormat("        ""from"": {0},", $item.from)
                [void]$strBld.AppendLine()
            }
            [void]$strBld.AppendFormat("        ""value"": ""{0}""", $item.value)
            [void]$strBld.AppendLine()
            if ( $loopCount -lt ($operations.count-1)) {
                [void]$strBld.AppendLine("   },")
                $loopCount = $loopCount + 1
            }
            else {
                [void]$strBld.AppendLine("   }")
            }
        }
        [void]$strBld.AppendLine("]")
        $outJson = $strBld.ToString()
    }
    else {
        #
        # its a single item, build a single item return string
        #
        $strBld = [System.Text.StringBuilder]::new()
        [void]$strBld.AppendLine("[")
        [void]$strBld.AppendLine("   {")
        [void]$strBld.AppendFormat("        ""op"": ""{0}"",", $operations.op)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendFormat("        ""path"": ""{0}"",", $operations.path)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendFormat("        ""from"": {0},", $operations.from)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendFormat("        ""value"": ""{0}""", $operations.value)
        [void]$strBld.AppendLine()
        [void]$strBld.AppendLine("   }")
        [void]$strBld.AppendLine("]")
        $outJSON = $strBld.ToString()
        Write-DebugInfo -ForegroundColor DarkRed $strBld.ToString()
    }
    return $outJSON
}