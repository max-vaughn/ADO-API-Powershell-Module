<# 
$Global:AadSupport = [hashtable]::Synchronized(@{
    Path = $PSScriptRoot
    ClientId = "a57bfff5-9e23-439d-9993-48d76ba688ca"
    RedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
    Logging = @{
        Enabled = $false
        Path = "c:/AadSupport/"
        FileName = ""
    }

    Powershell = @{
        Modules = @{
            AzureAd = @{
                Name = $null
                Version = $null
            }

            Azure = @{
                Name = $null
                Version = $null
            }
        }
    }

    Session = @{
        AadInstance = $null
        TenantId = $null
        TenantDomain = $null
        AccountId = $null
        Active = $false
        AzureEnvironmentName = "AzureCloud"
        AzureAccessToken = $null
        AzureGraphToken = $null
        AadAccessToken = $null
        AuthenticationType = $null
    }

    Runspace = @{
        AzureAd = @{
            Instance = [runspacefactory]::CreateRunspace()
            Connected = $false
        }
        MSOnline = @{
            Instance = [runspacefactory]::CreateRunspace()
            Connected = $false
        }
        Adal = @{
            Instance = [runspacefactory]::CreateRunspace()
        }
        SessionRunspace = @{
            Instance = [runspacefactory]::CreateRunspace()
        }
    }

    Common = @{
        AadInstance = "https://login.microsoftonline.com"
        TenantId = "common"
    }

    Clients = @{
        AzureAdPowerShell = @{
            ClientId = "1b730954-1685-4b74-9bfd-dac224a7b894"
            RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
        }
        AzurePowerShell = @{
            ClientId = "1950a258-227b-4e31-a9cf-717495945fc2"
            RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
        }
    }

    Resources = @{
        AadGraph = "https://graph.windows.net"
        MsGraph = "https://graph.microsoft.com"
        AzureRmApi = "https://management.azure.com"
        AzureServiceApi = "https://management.core.windows.net"
        KeyVault = "https://vault.azure.net"
    }
})

function New-AadSupportSession
{
    $Global:AadSupport.Session = @{
        AadInstance = $null
        TenantId = $null
        TenantDomain = $null
        AccountId = $null
        Active = $false
        AzureEnvironmentName = "AzureCloud"
        AzureAccessToken = $null
        AzureGraphToken = $null
        AadAccessToken = $null
    }
}

New-AadSupportSession

# Import the internal functions
$scripts = Get-ChildItem -Path $PSScriptRoot\Internals\*.ps1
foreach($script in $scripts) {
    Import-Module ($script.FullName) -Scope Global
}

# Import Logging function
$LogScript = "$PSScriptRoot\Internals\imports\Log-AadSupport.ps1"
. $LogScript

Write-Host ""
Write-Host "For more information about the 'Azure AD Support PowerShell Module' (AadSupport)..." -ForegroundColor Yellow
Write-Host "https://github.com/ms-willfid/aad-support-psh-module" -ForegroundColor Yellow

# Check if update is available
$remote_module = Find-Module -Name AadSupport
$local_module = Get-Module -ListAvailable -Name AadSupport
if ($local_module -and $remote_module.Version -gt $local_module.Version.toString()) {
    Write-Host ""
    Write-Host "There is a update available for AadSupport" -ForegroundColor Yellow
    Write-Host "Run the following command... 'Update-AadSupport'"
}

# Check if required PowerShell modules are installed
$module = Get-Module -ListAvailable -Name AzureAd
$modulep = Get-Module -ListAvailable -Name AzureAdPreview
$AzureModule = Get-Module -ListAvailable -Name Az.Accounts
$MsolModule = Get-Module -ListAvailable -Name MsOnline


# Check AzureAd
if ($module)
{
    $ModuleName = "AzureAD"
    $ModuleVersion = $module.Version.ToString()
    if($ModuleVersion -lt "2.0.2.76")
    {
        Write-Host ""
        Write-Host "Please update your AzureAd PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module AzureAd -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Check AzureAdPreview
if ($modulep)
{
    $ModuleName = "AzureADPreview"
    $ModuleVersion = $modulep.Version.ToString()
    if($ModuleVersion -lt "2.0.2.85")
    {
        Write-Host ""
        Write-Host "Please update your AzureAdPreview PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module AzureAdPreview -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Install Azure AD PowerShell if not installed
elseif (-not $module -and -not $modulep) {
    Write-Host ""
    Write-Host "AzureAD PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install AzureAD PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module AzureAd -Force -AllowClobber
        Write-Host "Finished installing AzureAD Module"
    }

    catch {
        throw "Unable to install AzureAD PowerShell module. Please run PowerShell as a Administrator."
    }
}

$Global:AadSupport.Powershell.Modules.AzureAd.Name = $ModuleName
$Global:AadSupport.Powershell.Modules.AzureAd.Version = $ModuleVersion


# Check Azure PowerShell is updated
if ($AzureModule)
{
    if($AzureModule.Count -gt 1)
    {
        Write-Host "You have more than one Azure Module installed. This may impose problems. Please un-install one."
    }

    if($AzureModule.Version.ToString() -lt "1.7.0")
    {
        Write-Host ""
        Write-Host "Please update your Az PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module Az -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Check if Azure  PowerShell is installed
elseif(-not $AzureModule) {
    Write-Host ""
    Write-Host "(Az)ure PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install (Az)ure PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module Az -Force -AllowClobber
        Write-Host "Finished installing (Az)ure Module"
    }

    catch {
        throw "Unable to install (Az)ure PowerShell module. Please run PowerShell as a Administrator."
    }
}

# Check MSOnline PowerShell is updated
if ($MsolModule)
{
    if($MsolModule.Version.ToString() -lt "1.1.166.0")
    {
        Write-Host ""
        Write-Host "Please update your MSOnline PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module MSOnline -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Check if MSOnline PowerShell is installed
elseif(-not $MsolModule) {
    Write-Host ""
    Write-Host "MSOnline PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install MSOnline PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module Az -Force -AllowClobber
        Write-Host "Finished installing MSOnline Module"
    }

    catch {
        throw "Unable to install MSOnline PowerShell module. Please run PowerShell as a Administrator."
    }
}

# GET ADAL INFO
#Get the module folder so we can load the ADAL DLLs we want
$modulebase = (Get-Module $ModuleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase
$Global:AadSupportAdalPath = $AdalPath = "{0}\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" -f $modulebase
$adalVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($Global:AadSupportAdalPath).FileVersion)




Load-AadSupportAdalAssembly

"ADAL Version: $adalVersion" | Log-AadSupport
"ADAL Path: $AdalPath" | Log-AadSupport

$Global:AadSupportModule = $true


# EXTENSION HELPER METHOS


[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')

function ShowEULAPopup
{
$EULA = New-Object -TypeName System.Windows.Forms.Form
$richTextBox1 = New-Object System.Windows.Forms.RichTextBox
$btnAcknowledge = New-Object System.Windows.Forms.Button
$btnCancel = New-Object System.Windows.Forms.Button

$EULA.SuspendLayout()
$EULA.Name = "EULA"
$EULA.Text = "Microsoft Diagnostic Tools End User License Agreement"

$richTextBox1.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$richTextBox1.Location = New-Object System.Drawing.Point(12,12)
$richTextBox1.Name = "richTextBox1"
$richTextBox1.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$richTextBox1.Size = New-Object System.Drawing.Size(776, 397)
$richTextBox1.TabIndex = 0
$richTextBox1.ReadOnly=$True
$richTextBox1.Add_LinkClicked({Start-Process -FilePath $_.LinkText})
$richTextBox1.Rtf = @"
{\rtf1\ansi\ansicpg1252\deff0\nouicompat{\fonttbl{\f0\fswiss\fprq2\fcharset0 Segoe UI;}{\f1\fnil\fcharset0 Calibri;}{\f2\fnil\fcharset0 Microsoft Sans Serif;}}
{\colortbl ;\red0\green0\blue255;}
{\*\generator Riched20 10.0.19041}{\*\mmathPr\mdispDef1\mwrapIndent1440 }\viewkind4\uc1 
\pard\widctlpar\f0\fs19\lang1033 MICROSOFT SOFTWARE LICENSE TERMS\par
Microsoft Diagnostic Scripts and Utilities\par
\par
{\pict{\*\picprop}\wmetafile8\picw26\pich26\picwgoal32000\pichgoal15 
0100090000035000000000002700000000000400000003010800050000000b0200000000050000
000c0202000200030000001e000400000007010400040000000701040027000000410b2000cc00
010001000000000001000100000000002800000001000000010000000100010000000000000000
000000000000000000000000000000000000000000ffffff00000000ff040000002701ffff0300
00000000
}These license terms are an agreement between you and Microsoft Corporation (or one of its affiliates). IF YOU COMPLY WITH THESE LICENSE TERMS, YOU HAVE THE RIGHTS BELOW. BY USING THE SOFTWARE, YOU ACCEPT THESE TERMS.\par
{\pict{\*\picprop}\wmetafile8\picw26\pich26\picwgoal32000\pichgoal15 
0100090000035000000000002700000000000400000003010800050000000b0200000000050000
000c0202000200030000001e000400000007010400040000000701040027000000410b2000cc00
010001000000000001000100000000002800000001000000010000000100010000000000000000
000000000000000000000000000000000000000000ffffff00000000ff040000002701ffff0300
00000000
}\par

\pard 
{\pntext\f0 1.\tab}{\*\pn\pnlvlbody\pnf0\pnindent0\pnstart1\pndec{\pntxta.}}
\fi-360\li360 INSTALLATION AND USE RIGHTS. Subject to the terms and restrictions set forth in this license, Microsoft Corporation (\ldblquote Microsoft\rdblquote ) grants you (\ldblquote Customer\rdblquote  or \ldblquote you\rdblquote ) a non-exclusive, non-assignable, fully paid-up license to use and reproduce the script or utility provided under this license (the "Software"), solely for Customer\rquote s internal business purposes, to help Microsoft troubleshoot issues with one or more Microsoft products, provided that such license to the Software does not include any rights to other Microsoft technologies (such as products or services). \ldblquote Use\rdblquote  means to copy, install, execute, access, display, run or otherwise interact with the Software. \par

\pard\widctlpar\par

\pard\widctlpar\li360 You may not sublicense the Software or any use of it through distribution, network access, or otherwise. Microsoft reserves all other rights not expressly granted herein, whether by implication, estoppel or otherwise. You may not reverse engineer, decompile or disassemble the Software, or otherwise attempt to derive the source code for the Software, except and to the extent required by third party licensing terms governing use of certain open source components that may be included in the Software, or remove, minimize, block, or modify any notices of Microsoft or its suppliers in the Software. Neither you nor your representatives may use the Software provided hereunder: (i) in a way prohibited by law, regulation, governmental order or decree; (ii) to violate the rights of others; (iii) to try to gain unauthorized access to or disrupt any service, device, data, account or network; (iv) to distribute spam or malware; (v) in a way that could harm Microsoft\rquote s IT systems or impair anyone else\rquote s use of them; (vi) in any application or situation where use of the Software could lead to the death or serious bodily injury of any person, or to physical or environmental damage; or (vii) to assist, encourage or enable anyone to do any of the above.\par
\par

\pard\widctlpar\fi-360\li360 2.\tab DATA. Customer owns all rights to data that it may elect to share with Microsoft through using the Software. You can learn more about data collection and use in the help documentation and the privacy statement at {{\field{\*\fldinst{HYPERLINK https://aka.ms/privacy }}{\fldrslt{https://aka.ms/privacy\ul0\cf0}}}}\f0\fs19 . Your use of the Software operates as your consent to these practices.\par

\pard\widctlpar\par

\pard\widctlpar\fi-360\li360 3.\tab FEEDBACK. If you give feedback about the Software to Microsoft, you grant to Microsoft, without charge, the right to use, share and commercialize your feedback in any way and for any purpose.\~ You will not provide any feedback that is subject to a license that would require Microsoft to license its software or documentation to third parties due to Microsoft including your feedback in such software or documentation. \par

\pard\widctlpar\par

\pard\widctlpar\fi-360\li360 4.\tab EXPORT RESTRICTIONS. Customer must comply with all domestic and international export laws and regulations that apply to the Software, which include restrictions on destinations, end users, and end use. For further information on export restrictions, visit {{\field{\*\fldinst{HYPERLINK https://aka.ms/exporting }}{\fldrslt{https://aka.ms/exporting\ul0\cf0}}}}\f0\fs19 .\par

\pard\widctlpar\par

\pard\widctlpar\fi-360\li360\qj 5.\tab REPRESENTATIONS AND WARRANTIES. Customer will comply with all applicable laws under this agreement, including in the delivery and use of all data. Customer or a designee agreeing to these terms on behalf of an entity represents and warrants that it (i) has the full power and authority to enter into and perform its obligations under this agreement, (ii) has full power and authority to bind its affiliates or organization to the terms of this agreement, and (iii) will secure the permission of the other party prior to providing any source code in a manner that would subject the other party\rquote s intellectual property to any other license terms or require the other party to distribute source code to any of its technologies.\par

\pard\widctlpar\par

\pard\widctlpar\fi-360\li360\qj 6.\tab DISCLAIMER OF WARRANTY. THE SOFTWARE IS PROVIDED \ldblquote AS IS,\rdblquote  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL MICROSOFT OR ITS LICENSORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\par

\pard\widctlpar\qj\par

\pard\widctlpar\fi-360\li360\qj 7.\tab LIMITATION ON AND EXCLUSION OF DAMAGES. IF YOU HAVE ANY BASIS FOR RECOVERING DAMAGES DESPITE THE PRECEDING DISCLAIMER OF WARRANTY, YOU CAN RECOVER FROM MICROSOFT AND ITS SUPPLIERS ONLY DIRECT DAMAGES UP TO U.S. $5.00. YOU CANNOT RECOVER ANY OTHER DAMAGES, INCLUDING CONSEQUENTIAL, LOST PROFITS, SPECIAL, INDIRECT, OR INCIDENTAL DAMAGES. This limitation applies to (i) anything related to the Software, services, content (including code) on third party Internet sites, or third party applications; and (ii) claims for breach of contract, warranty, guarantee, or condition; strict liability, negligence, or other tort; or any other claim; in each case to the extent permitted by applicable law. It also applies even if Microsoft knew or should have known about the possibility of the damages. The above limitation or exclusion may not apply to you because your state, province, or country may not allow the exclusion or limitation of incidental, consequential, or other damages.\par

\pard\widctlpar\par

\pard\widctlpar\fi-360\li360 8.\tab BINDING ARBITRATION AND CLASS ACTION WAIVER. This section applies if you live in (or, if a business, your principal place of business is in) the United States.  If you and Microsoft have a dispute, you and Microsoft agree to try for 60 days to resolve it informally. If you and Microsoft can\rquote t, you and Microsoft agree to binding individual arbitration before the American Arbitration Association under the Federal Arbitration Act (\ldblquote FAA\rdblquote ), and not to sue in court in front of a judge or jury. Instead, a neutral arbitrator will decide. Class action lawsuits, class-wide arbitrations, private attorney-general actions, and any other proceeding where someone acts in a representative capacity are not allowed; nor is combining individual proceedings without the consent of all parties. The complete Arbitration Agreement contains more terms and is at {{\field{\*\fldinst{HYPERLINK https://aka.ms/arb-agreement-4 }}{\fldrslt{https://aka.ms/arb-agreement-4\ul0\cf0}}}}\f0\fs19 . You and Microsoft agree to these terms. \par

\pard\widctlpar\par

\pard\widctlpar\fi-360\li360 9.\tab LAW AND VENUE. If U.S. federal jurisdiction exists, you and Microsoft consent to exclusive jurisdiction and venue in the federal court in King County, Washington for all disputes heard in court (excluding arbitration). If not, you and Microsoft consent to exclusive jurisdiction and venue in the Superior Court of King County, Washington for all disputes heard in court (excluding arbitration).\par

\pard\widctlpar\par

\pard\widctlpar\fi-360\li360 10.\tab ENTIRE AGREEMENT. This agreement, and any other terms Microsoft may provide for supplements, updates, or third-party applications, is the entire agreement for the software.\par

\pard\sa200\sl276\slmult1\f1\fs22\lang9\par

\pard\f2\fs17\lang2057\par
}
"@
$richTextBox1.BackColor = [System.Drawing.Color]::White
$btnAcknowledge.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$btnAcknowledge.Location = New-Object System.Drawing.Point(544, 415)
$btnAcknowledge.Name = "btnAcknowledge";
$btnAcknowledge.Size = New-Object System.Drawing.Size(119, 23)
$btnAcknowledge.TabIndex = 1
$btnAcknowledge.Text = "Accept"
$btnAcknowledge.UseVisualStyleBackColor = $True
$btnAcknowledge.Add_Click({$EULA.DialogResult=[System.Windows.Forms.DialogResult]::Yes})
$btnCancel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$btnCancel.Location = New-Object System.Drawing.Point(669, 415)
$btnCancel.Name = "btnCancel"
$btnCancel.Size = New-Object System.Drawing.Size(119, 23)
$btnCancel.TabIndex = 2
$btnCancel.Text = "Decline"
$btnCancel.UseVisualStyleBackColor = $True
$btnCancel.Add_Click({$EULA.DialogResult=[System.Windows.Forms.DialogResult]::No})

$EULA.AutoScaleDimensions = New-Object System.Drawing.SizeF(6.0, 13.0)
$EULA.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$EULA.ClientSize = New-Object System.Drawing.Size(800, 450)
$EULA.Controls.Add($btnAcknowledge)
$EULA.Controls.Add($btnCancel)
$EULA.Controls.Add($richTextBox1)
$EULA.AcceptButton=$btnAcknowledge
$EULA.CancelButton=$btnCancel
$EULA.ResumeLayout($false)
$EULA.Size = New-Object System.Drawing.Size(800, 650)

Return ($EULA.ShowDialog())
}

function ShowEULAIfNeeded($toolName)
{
	$eulaRegPath = "HKCU:Software\Microsoft\CESDiagnosticTools"
	$eulaAccepted = "No"
	$eulaValue = $toolName + " EULA Accepted"
	if(Test-Path $eulaRegPath)
	{
		$eulaRegKey = Get-Item $eulaRegPath
		$eulaAccepted = $eulaRegKey.GetValue($eulaValue, "No")
	}
	else
	{
		$eulaRegKey = New-Item $eulaRegPath
	}

	if($eulaAccepted -eq "No")
	{
		$eulaAccepted = ShowEULAPopup
		if($eulaAccepted -eq [System.Windows.Forms.DialogResult]::Yes)
		{
        	$eulaAccepted = "Yes"
            $ignore = New-ItemProperty -Path $eulaRegPath -Name $eulaValue -Value $eulaAccepted -PropertyType String -Force
		}
	}
	return $eulaAccepted
}

ShowEulaIfNeeded("AadSupport")
#>
$global:strPersonalToken = "poodle"
$global:strOrgUri = ""
$global:strEncodedPersonalToken = ""
$global:WikiInfo = $null
$global:gHeaders = $null
$global:DefaultContext = $null
[bool]$global:debugCmdlets = $false
$global:ResourceIds =  @{
        account = "0d55247a-1c47-4462-9b1f-5e2125590ee6";
        build = "5d6898bb-45ec-463f-95f9-54d49c71752e";
        collection = "79bea8f8-c898-4965-8c51-8bbc3966faa8";
        core = "79134c72-4a58-4b42-976c-04e7115f32bf";
        dashboard = "31c84e0a-3ece-48fd-a29d-100849af99ba";
        delegatedAuth = "a0848fa1-3593-4aec-949c-694c73f4c4ce";
        discussion = "6823169a-2419-4015-b2fd-6fd6f026ca00";
        distributedtask = "a85b8835-c1a1-4aac-ae97-1c3d0ba72dbd";
        drop = "7bf94c77-0ce1-44e5-a0f3-263e4ebbf327";
        extensionManagement = "6c2b0933-3600-42ae-bf8b-93d4f7e83594";
        favorite = "67349c8b-6425-42f2-97b6-0843cb037473";
        git = "4e080c62-fa21-4fbc-8fef-2a10a2b38049";
        graph = "4e40f190-2e3f-4d9f-8331-c7788e833080";
        memberEntitlementManagement = "68ddce18-2501-45f1-a17b-7931a9922690";
        NuGet = "b3be7473-68ea-4a81-bfc7-9530baaa19ad";
        npm = "4c83cfc1-f33a-477e-a789-29d38ffca52e";
        package = "45fb9450-a28d-476d-9b0f-fb4aedddff73";
        packageing = "7ab4e64e-c4d8-4f50-ae73-5ef2e21642a5";
        pipelines = "2e0bf237-8973-4ec9-a581-9c3d679d1776";
        policy = "fb13a388-40dd-4a04-b530-013a739c72ef";
        profile = "8ccfef3d-2b87-4e99-8ccb-66e343d2daa8";
        release = "efc2f575-36ef-48e9-b672-0c6fb4a48ac5";
        reporting = "57731fdf-7d72-4678-83de-f8b31266e429";
        search = "ea48a0a1-269c-42d8-b8ad-ddc8fcdcf578";
        test = "3b95fb80-fdda-4218-b60e-1052d070ae6b";
        testresults = "c83eaf52-edf3-4034-ae11-17d38f25404c";
        tfvc = "8aa40520-446d-40e6-89f6-9c9f9ce44c48";
        user = "970aa69f-e316-4d78-b7b0-b7137e47a22c";
        wit = "5264459e-e5e0-4bd8-b118-0985e68a4ec5";
        work = "1d4f49f9-02b9-4e26-b826-2cdb6195f2a9";
        worktracking = "85f8c7b6-92fe-4ba6-8b6d-fbb67c809341"
    
}

