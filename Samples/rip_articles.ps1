param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'D:\data\davidtext.txt',
    [string] $OutData = 'D:\data\dvidripped.txt',
    [string] $OutData2 = 'D:\data\dvidrippednumbered.txt',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
# Read the file line by line
$linesOut = @()
$numberedLines = @()
Get-Content $InputData | ForEach-Object {
    # Process each line
    $line = $_
    #
    # Check to see if the line starts with a number
    #
    if ( $line.Length -gt 5 ) {
        if ($line -match '^\d+\.\s') {
            #
            # Pull the string between the ** .... **
            # 
            $numberedLines = $numberedLines + $line
            if ($line -match '\*\*(.*?)\*\*') {
                $boundedText = $matches[1]
                $linesOut = $linesOut + $boundedText
            }
            else {
                #Write-Output "No bounded text found in line: $line"
            }
        }
        else {
            #Write-Output "No match: $line"
        }
    }
}
$linesOut | Out-File  -FilePath $OutData -Force
$numberedLines | Out-File  -FilePath $OutData2 -Force
