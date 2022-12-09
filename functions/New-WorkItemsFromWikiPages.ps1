       # $res = Get-WikiFolderDocs -basePath "GeneralPages/AAD/Developer" -wikiUri $WikiInfo.url -headers $gHeaders -returnPageInfo $true 
        # New-WorkItemsFromWikiPages -wikiPages $res -Context $DevExpContext -areaPath "Community - Identity Developer Experiences \\Troubleshooting Guides" -titlePrefix "[WK] MBI Template Update: " -description "$desText" -ReplaceTemplates $repItems -ParentLinkPath $linkUrl -workItemType task -iterationPath $iterationPath   

        function New-WorkItemsFromWikiPages {
            param (
                [Parameter()]
                $wikiPages = $null,
                $Context,
                [string] $areaPath = $null,
                [string] $iterationPath = $null,
                [string] $titlePrefix = $null,
                [string] $description = $null,
                [PSObject] $ReplaceTemplates = $null,
                [string] $ParentlinkPath = $null,
                [string] $workItemType = $null
            )
            if ( $wikiPages -eq $null ) {
                $outErr = [string]::Format("Missing PSObject information for list of pages.  Must the output of Get-WikiFoldersDocs with -returnpageInfo set to `$true")
                throw $outErr
            }
            else {
                foreach ( $item in $wikiPages) {
                    $properties = @()
                    $itemName = $item.gitItemPath
                    $itemName = $itemName.SubString($itemName.LastIndexOf('/') + 1)
                    #
                    # Create the title for the work item and 
                    # add the add operation to the properties list
                    #
                    if ( $titlePrefix.Length -GT 0 ) {
                        #
                        # The user has provided a prefix for the title.
                        # Build the title [$titlePrefix] - [.MD File name]
                        #
        
                        $itemName = [string]::Format("{0} - {1}", $titlePrefix, $itemName)
                        $property = new-ADOCreateOperation -Operation add -Path "/fields/System.Title" -Value $itemName -From "null"
                        $properties = $properties + $property
                    }
                    else {
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.Title" -Value $itemName  
                        $properties = $properties + $property
                    }
                    if ( $areaPath.Length -GT 0 ) {
                        #
                        # There is an Area Path value, add this value to the properities list as well.
                        #
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.AreaPath" -Value $areaPath 
                        $properties = $properties + $property
                    }
                    if( $iterationPath.Length -gt 0 ) {
                                                #
                        # There is an iteration Path value, add this value to the properities list as well.
                        #
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.IterationPath" -Value $iterationPath 
                        $properties = $properties + $property
                    }
                    if ( $description.Length -GT 0 ){
                        #
                        # There is a description to add Check to see if there
                        # is a ReplaceTemplates array that contains a list of objects
                        # with properties:
                        # FromTag = "String Tag Value"
                        # ToValue = "Item.property" where propertie is a wikiPage property value
                        # https://docs.microsoft.com/en-us/rest/api/azure/devops/wiki/pages/get%20page%20by%20id?view=azure-devops-rest-6.0#wikipage
                        # currently the only one supported is page ID
                        # 
                        # Other wise a straght substition will be done.
                        $tmpDescription = $description
                        if( $null -ne $ReplaceTemplates ){
                            #
                            # There is a replacement item in the templates,
                            # roll through all the objects and do a string.Replace operation
                            #
                            foreach( $template in $ReplaceTemplates )
                            {
                                if( $template.ToValue -eq "Item.ID" )
                                {
                                  $tmpDescription = $tmpDescription.Replace($template.FromTag, $item.ID )
                                }
                                elseif ($template.ToValue -eq "Item.gitItemPath" ) 
                                {
                                    $tmpDescription = $tmpDescription.Replace($template.FromTag, $item.gitItemPath )
                                    $dbgString = [string]::Format(" Create-WorkItemsFromWikiPages: Item.gitItemPath: {0} Match: *{1}*", $item.gitItemPath, $template.FromTag)
                                    Write-DebugInfo -ForegroundColor DarkMagenta -debugString $dbgString
                                }
                                else 
                                {
                                    $tmpDescription = $tmpDescription.Replace($template.FromTag, $template.Value )
                                }
                            }
                        }
                        $property = new-ADOCreateOperation -Operation add -From null -Path "/fields/System.Description" -Value $tmpDescription
                        $properties = $properties + $property
                        $global:gProperties = $properties
                }
                $wrkItem = new-ADOworkitem -Operations $properties -Project $context.ProjectID -orgUrl $context.OrgUrl -baseUrl $context.OrgUrl -headers $Context.Headers -workItemType $workItemType
                if( $ParentlinkPath.Length -gt 0 ){
                    # 
                    # We have a parent item to link this item with.
                    # Create the to the parent item
                    #
                   $retItem =  Add-ADOLinkItem -linkItemFullUrl $ParentlinkPath -workItemFullUrl $wrkItem.url -headers $Context.Headers
                }
        
            }
        }
    }
