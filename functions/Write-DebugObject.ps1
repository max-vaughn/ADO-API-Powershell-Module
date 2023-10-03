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
        $outStr = [System.Text.StringBuilder]::new()
        if( $null -ne $inputObject )
        {
            # 
            # We have an ojbect.  If its a dictionary, lists the key/value pairs
            #
             $tIO = $inputObject.GetType().ToString()
            if( $tIO.Contains("Generic.Dictionary")){
                #
                # Object is a string, now lets enumerate and build an output string with the properties.
                #
                $outStr.AppendLine( $debugString  )
                $outStr.AppendLine("{")
                foreach( $kv in $inputObject.Keys){
                    $v = "    " + $kv + ": " + $inputObject[$kv]
                    $outStr.AppendLine( $v )
                }
                $outStr.AppendLine("}")
            }
            elseif ($tIO.Contains("Automation.PSCustomObject")) {
                #
                # The object is a PSCustomerObject
                #
                $outStr.AppendLine( $debugString )
                $outStr.AppendLine("{")
                foreach($property in $inputObject.psobject.properties.name ){
                    $outs = [string]::Format("    {0,-15} : {1}", $property, $inputObject.$porperty )
                    $outStr.AppendLine($outs)
                }
                $outStr.AppendLine("}")
            }
        }
        else {
            $outStr.AppendFormat("Write-DebugObject: Objecttype not supported" )
        }
       Write-Host -ForegroundColor $ForegroundColor $outStr
    }
}