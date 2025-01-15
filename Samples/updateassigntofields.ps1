param (
    [string] $pertok = "",
    #[string] $PathVar = "GeneralPages/AAD/AAD%20Account%20Management/AAD%20Government%20Troubleshooting/TSG%3A%20Password%20Reset%20Requests%20for%20Azure%20Government%20Tenants",
    [string] $InputData = 'D:\data\20_30_percent_tagged_items_with_Comm.csv',
    [string] $OutData = 'D:\data\20_30_percent_tagged_items_with_Comm_new.csv',
    #[string] $PathVar = "%2FAuthentication%2FFIDO2%20passkeys%2FFIDO2%3A%20Data%20analysis",
    #[string] $PathVar = ""
    [bool] $debugcmd = $false
)
$TskObjs = Import-Csv -Path $InputData 
$outItems = @()# Define the CSV content
$csvContent = @"
Community;Tag;Contact
ADFS And WAP;cw.comm-adfs;losun@microsoft.com
Application Experiences;cw.comm-appex;aharrison@microsoft.com
Cloud Device Identity;cw.comm-cauthex;ulyssesneves@microsoft.com
Hybrid Auth Experience;cw.comm-hybauth;levireed@microsoft.com
Identity Security and Protection;cw.comm-idsp;chkoide@microsoft.com
Deverloper Experiences;cw.comm-devex;secorre@microsoft.com
Strong Auth Methods;cw.comm-strauth;ulyssesneves@microsoft.com
Sync-provisioning;cw.comm-sync;adreysan@microsoft.com
Organization Management;cw.comm-orgmgt;jtelagalapud@microsoft.com
Exteneral Identity Management;cw.comm-extidmgt;nubartol@microsoft.com
Security and Access Management;cw.comm-secaccmgt;chkoide@microsoft.com
Object and Principal Management;cw.comm-objprinmgt;ruigirao@microsoft.com
M365 Identity;cw.comm-M365ID;jiatan@microsoft.com
"@

# Convert the CSV content to objects
$csvData = $csvContent | ConvertFrom-Csv -Delimiter ';'

# Initialize an empty hashtable
$CommCon = @{}

# Populate the hashtable
foreach ($row in $csvData) {
    $CommCon[$row.Tag] = $row.Contact
}
foreach( $tobj in $TskObjs ){
    if( ($tobj.CommTag.Length -gt 0 ) -and ( $tobj.'Assigned To'.Length -eq 0 ) ){
        $contact = $CommCon[$tobj.CommTag]
        $tobj.'Assigned To' = $contact
    }
}
$TskObjs | Export-Csv -Path $OutData -Force 