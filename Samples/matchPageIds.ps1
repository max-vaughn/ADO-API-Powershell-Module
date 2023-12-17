param (
    [string] $pertok = "",
    [string] $AzureData = "",
    [string] $KeyVaultData = ""
)
#$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$AZObjs = Import-Csv -Path $AzureData 
$KVObjs = Import-Csv -Path $KeyVaultData
foreach( $item in $AZobjs ){
    $FileName = Split-Path -Path $item.gitItemPath -Leaf
    $item = $item | Add-Member -Name "FileName" -Type NoteProperty -Value $FileName
}
foreach( $item in $KVObjs ){
    $FileName = Split-Path -Path $item.gitItemPath -Leaf
    $item = $item | Add-Member -Name "FileName" -Type NoteProperty -Value $FileName
}
foreach( $kvItem in $kvObjs ){
    foreach( $adItem in $AZObjs ){
        if( $adItem.FileName -eq $kvItem.FileName ){
            $adItem = $adItem | Add-Member -Name "KVpageId" -Type NoteProperty -Value $kvItem.pageID
            break
        }
    }
}
$AZObjs.count
$AZObjs | export-csv -NoTypeInformation -Path 'D:\data\AzureADwithKVpagIds.csv' -Force
