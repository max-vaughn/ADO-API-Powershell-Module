function Get-ADOProjectId {
    param (
        [PSObject] $projects = $null,
        [string] $project = $null,
        [string] $organization = $null,
        [hashtable] $headers = $global:gHeaders
    )
    if ( $null -eq $project ) {
        throw "Missing project name.  Must have a project name to search for."
    }
    else {
        #
        # We have a project ot lookup.
        # We now need either an organization to create projects list
        # Or
        # a projects list
        #
        if ( ($null -eq $projects) -and ($null -eq $organization) ) {
            throw "Must have either an organization or a projects collection from Get-Projects cmdlet"
        }
        elseif( $null -eq $projects ){
            #
            # We know that we have an organization, build the projects list
            # from the organization
            #
            elseif ( $null -eq $organization ) { 
                throw "Missing project and organization, must have one or the other"
            }
            $srcList = Get-ADOProjects -organization $organization -headers $headers
        }
        else {
            #
            # Work with the current projects list
            #
            $srcList = $projects
        }
        $projectID = ""
        $global:SomeList =  $srcList
        foreach( $item in $srcList ){
            if( $item.name -eq $project )
            {
                $projectID = $item.id
                # Write-Host $item
                $dbgStr = [string]::Format("Get-ADOProjectId -> PROJECT NAME MATCH *project:{0}*-*Project ID: {1}", $item.name, $item.id )
                Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
                break;
            }
        }
        $dbgStr = [string]::Format("Get-ADOProjectId -> *project:{0}*-*Project ID: {1}", $project, $projID )
        Write-DebugInfo -ForegroundColor DarkBlue $dbgStr
        return $projectID
        }
        return $null
}