<#
==================> Function Invoke-RestMethodWithPaging <==================
#>


<#
.SYNOPSIS
Invokes a REST request and checks the return header values x-ms-continuationToken 
value to see if another request should be sent


.DESCRIPTION
Invokes a rest request and implements an ADO APi paging method examing the values in the
x-ms-continuationToken return header value to see if another request needs to be made.  

Requests continue to be sent until the x-ms-continuationToken is not returned.

.PARAMETER Method
Rest METHOD to execute expected to be the GET method to generate a complete list for the API URI
based on the ADO API paging mechanisms.

.Parameter Uri
ADO API to execute without the continuationToken parameter

.PARAMETER Headers
Hashtable containing the headers that will be added to the Invoke-RestMethod cmdlet.  The header must 
contain the Authorization header value.  Use the Set-ADOAuthHeaders cmdlet with a Personal Access Token to 
create a header hashtable.

.OUTPUTS
Combinded results from a given ADO api call


.EXAMPLE


NA

.EXAMPLE

NA

.NOTES
General notes
#>
function Invoke-RestMethodWithPaging {
    param(
     [string] $Method,
     [string] $Uri,
     $Headers
    )
    $result = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -ResponseHeadersVariable resHeaders
    $continuationToken = $resHeaders['x-ms-continuationtoken']
    while( $continuationToken -ne $null )
    {
       $uric = [string]::Format("{0}&continuationToken={1}", $Uri, [string]$continuationToken)
       $dbgStr = [string]::Format("Invoke-RestMethodWithPaging: *Url-> {0}* *continuationToken -> {1}*", $uric, [string]$continuationToken)
       Write-DebugInfo -debugString $dbgStr -ForegroundColor DarkMagenta
       $result2 = Invoke-RestMethod -Method $Method -Uri $uric -Headers $Headers -ResponseHeadersVariable resHeaders
       $continuationToken = $resHeaders['x-ms-continuationtoken']
       $result.Value = $result.Value + $result2.Value
       $dbgStr = [string]::Format("Invoke-RestMethodWithPaging: *returned objects-> {0}* *Total Objects-> {1}* *continuationToken -> {2}*", $result2.count, $result.count, [string]$continuationToken)
       Write-DebugInfo -debugString $dbgStr -ForegroundColor DarkMagenta
    }
    return $result
 }
 