
#Introduction 

The only file in this folder is DevOpsCmdlets.psm1.  This file contains the initial versions of the cmdlets included in this project.  The cmdlets focused on retrieving Wiki information and creating items in the Issues collections.

I am working on a more elegant installing process.  At present, using the build step below, you can rebuild the PSM1 file from all of the script files located in the functions folder.

#build step
Temporarily, there is a single build step for this repo.  In the powershell terminal window, if you have not changed the default directory, this script string should work to build the complete PSM1 file:
```Powershell
del .\AllInOnePSM1\DevOpsCmdlets.psm1;dir .\functions | get-content >> .\AllInOnePSM1\DevOpsCmdlets.psm1
```

#Import instructions
The PSM1 file is loaded simple by using the Import-Module command and providing the full path to the location of the DevOpsCmdlets.psm1 file.