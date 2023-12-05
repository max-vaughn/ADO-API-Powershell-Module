param (
    [string] $pertok,
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
   # [string] $PathVar = "Authentication/FIDO2%20passkeys/FIDO2%3A%20Case%20scoping%20questions",
    # [string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$Context = Get-ADOContext -pat $perTok -organization "Supportability" -project "AzureAD"
$retH = new-object psobject
$page = Get-WikiPage -WikiUri $Context.WikiInfo.Value[0].url -basePath $PathVar -headers $Context.Headers -recursionLevel oneLevel -includeContent $true 
$pagePath = Get-pagePath -remoteUrl $page.remoteUrl
