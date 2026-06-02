<#

###########################
#
#    prepare Admin PC
#
###########################

1) Install .NET 11 SDK
2) Add nuget.org as source
3) Install WIX
4) Download and install WIX Toolkit 3.1...
5) Download and install Orca (MSI-Table editor)


###########################
#
#    Download and extract your SoftwarePackage_Setup.Exe  ( WIX package )
#
###########################
A) Download and extract your desired software package  - e.g.  DELL DUP-format     Dell-SupportAssist-OS-Recovery-Plugin_XVV9X_WIN64_5.5.16.1_A00.EXE
B) Extract your desired software package (WIX-package) - e.g.       WIX-formmat    "C:\Temp\DellUpdateSupportAssistPlugin.exe"        
C) Rename file ( extracted-by-dark.exe ) to MSI      C:\Temp\Extracted\AttachedContainer\FileXyz  => FileXyz.MSI
D) extract MSI content     C:\Temp\ExtractedMSI

# ###############################################
1) Install .NET 11 SDK
# ###############################################

https://aka.ms/dotnet/download

    .NET 11 SDK 

https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/sdk-10.0.300-windows-x64-installer


# ###############################################
2) Add nuget.org as source
# ###############################################

Add nuget.org as source
    dotnet nuget add source "https://api.nuget.org/v3/index.json" --name "nuget.org"

Verify that this source was added:
    dotnet nuget list source

Re-Open a new CMD Shell ( after .NET SDK is installed)


# ###############################################
3) Install WIX
# ###############################################

(new) cmd-Shell:  
    
    dotnet tool install --global wix --version 7.0.0
    wix --version

# ###############################################
4) Download and install WIX Toolkit 3.1...
# ###############################################

view the video  https://www.youtube.com/watch?v=F4K0kXv4-TQ
    
    https://www.firegiant.com/wixtoolset/

    https://github.com/wixtoolset/wix3/releases/tag/wix3141rtm

# ###############################################
5) Download and install Orca (MSI-Table editor
# ###############################################

        is part of the MS-Platform-SDK
        
        https://learn.microsoft.com/en-gb/windows/apps/windows-sdk/
        https://learn.microsoft.com/en-gb/windows/apps/windows-sdk/downloads-archive    - at least "Windows 7 - SDK" contains ORCA.MSI 
        
        Download and install  "Windows - SDK"   - only "M;SI-Tools" ~ 18 MB
        Install ORCA from   "C:\Program Files (x86)\Windows Kits\10\bin\10.0.28000.0\x86\Orca-x86_en-us.msi"

        "C:\Program Files (x86)\Orca\Orca.exe"



      
# ###############################################
A) Download and extract your desired software package  - e.g.  DELL DUP-format     Dell-SupportAssist-OS-Recovery-Plugin_XVV9X_WIN64_5.5.16.1_A00.EXE
# ###############################################

    Dell-SupportAssist-OS-Recovery-Plugin_XVV9X_WIN64_5.5.16.1_A00.exe /s /e=C:\Temp

    =>  "C:\Temp\DellUpdateSupportAssistPlugin.exe"                                #     Dell-SupportAssist-OS-Recovery-Plugin

# ###############################################
B) Extract your desired software package (WIX-package) - e.g.       WIX-formmat    "C:\Temp\DellUpdateSupportAssistPlugin.exe"  
# ###############################################
    
#    https://stackoverflow.com/questions/1547809/extract-msi-from-exe
#         dark.exe -x outputfolder WixPackage-DownloadedSetup.Exe

    C:\Temp\DellUpdateSupportAssistPlugin.exe                                      #     Dell-SupportAssist-OS-Recovery-Plugin.exe - Software-Setup.exe created by WIX
    C:\Temp\Extracted
    
    "C:\Program Files (x86)\WiX Toolset v3.14\bin\dark.exe"                        #    part of  WIX Toolkit 3.1


    "C:\Program Files (x86)\WiX Toolset v3.14\bin\dark.exe"  " C:\Temp\DellUpdateSupportAssistPlugin.exe" -x C:\Temp\Extracted

# ###############################################
C) Rename file ( extracted-by-dark.exe ) to MSI      C:\Temp\Extracted\AttachedContainer\FileXyz  => FileXyz.MSI
# ###############################################
 
check extracted content in folder C:\Temp\Extracted

    example:     C:\Temp\Extracted\AttachedContainer
    
    Rename       C:\Temp\Extracted\AttachedContainer\FileXyz  => FileXyz.MSI
    
    Verify FileXyz.MSI  properties - is it really an MSI

    Anlyse MSI logik
    -  use MS-Orca to verify content and actions of MSI
         - https://learn.microsoft.com/en-us/windows/win32/msi/orca-exe

# ###############################################
D) extract MSI content     C:\Temp\ExtractedMSI
# ###############################################
 
    MsiExec.exe /a "C:\Dell\XVV9X\Expanded\AttachedContainer\PluginSetup.msi" TARGETDIR=C:\Dell\XVV9X\ExtractedMSI

#>
