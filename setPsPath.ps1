param (
    [string] $ModulePath
)
$pathVal = $ModulePath + $env:PSModulePath
$env:PSModulePath = $pathVal
$env:PSModulePath