function new-ADOCreateOperation {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $operation,
        [string] $value,
        [string] $from = "",
        [string] $path = ""
    )
    $retItem = New-Object PSobject
    $retItem | Add-Member -Name "op" -Value $operation -MemberType NoteProperty
    $retItem | Add-Member -Name "value" -Value $value -MemberType NoteProperty
    $retItem | Add-Member -Name "from" -Value $from -MemberType NoteProperty
    $retItem | Add-Member -Name "path" -Value $path -MemberType NoteProperty    
    return $retItem
}