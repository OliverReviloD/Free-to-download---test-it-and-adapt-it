<#     https://www.windowspage.de/tipps/021753.html


    Windows Subsystem for Linux (WSL)
        https://learn.microsoft.com/de-de/windows/wsl/about

    ---------------------------------
    elevated cmd shell

            wsl --help
    
            Usage: wsl.exe [Argument] [Options...] [CommandLine]

            Arguments for running Linux binaries:
            If no command line is provided, wsl.exe launches the default shell.

            ....


            wsl --list --all
                    Windows Subsystem for Linux has no installed distributions.
                    Distributions can be installed by visiting the Microsoft Store:     https://aka.ms/wslstore

    ---------------------------------

    Windows Explorer: If the option 'Show all folders' is enabled in the explorer folder Options, then the 'Linux' entry will always get displayed in Windows Explorer navigation pane.


    HKEY_CLASSES_ROOT\CLSID\{B2B4A4D1-2754-4140-A2EB-9A76D9D7CDC6}
    
        "System.IsPinnedToNameSpaceTree"    DWORD

        System.IsPinnedToNameSpaceTree:
                0 = The "Linux" entry is hidden from the Windows Explorer navigation pane when Linux distributions (WSL) are installed.
                1 = The "Linux" entry is displayed in the Windows Explorer navigation pane when Linux distributions (WSL) are installed. (Default)

#>  




Get-AppxPackage | sort Name | ft
<#
    Name                                        Publisher                                     PublisherId   Architecture ResourceId Version            PackageFamilyName                                         PackageFullName                                                                         InstallLocation                                                                                 
    ----                                        ---------                                     -----------   ------------ ---------- -------            -----------------                                         ---------------                                                                         ---------------                                                                                 
    CanonicalGroupLimited.UbuntuonWindows       CN=23596F84-C3EA-4CD8-A7DF-550DCE37BCD0       79rhkp1fndgsc          X64            2004.2022.1.0      CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc       CanonicalGroupLimited.UbuntuonWindows_2004.2022.1.0_x64__79rhkp1fndgsc                  C:\Program Files\WindowsApps\CanonicalGroupLimited.UbuntuonWindows_2004.2022.1.0_x64__79rhkp1...
#>

Get-AppxPackage -Allusers | Where { $_.Name -like "*CanonicalGroupLimited*" }
Get-AppxPackage -Allusers | Where { $_.Name -like "*CanonicalGroupLimited*" } | Remove-AppPackage -allusers


Get-AppxProvisionedPackage  -online | sort DisplayName | ft
<#
    DisplayName                           PackageName                                                                 PublisherId   Version            Architecture ResourceId InstallLocation                                                                                                                              Region
    -----------                           -----------                                                                 -----------   -------            ------------ ---------- ---------------                                                                                                                              ------
    CanonicalGroupLimited.UbuntuonWindows CanonicalGroupLimited.UbuntuonWindows_2004.2022.1.0_neutral_~_79rhkp1fndgsc 79rhkp1fndgsc 2004.2022.1.0                11 ~          C:\Program Files\WindowsApps\CanonicalGroupLimited.UbuntuonWindows_2004.2022.1.0_neutral_~_79rhkp1fndgsc\AppxMetadata\AppxBundleManifest.xml       
#>

Get-AppxProvisionedPackage -online | Where { $_.PackageName -like "*CanonicalGroupLimited.UbuntuonWindows*" } 


& C:\Windows\System32\dism.exe /online /get-Features /format:Table | find /i "linux"
#   => Microsoft-Windows-Subsystem-Linux           | Enabled

& C:\Windows\System32\dism.exe /online /Disable-Feature /FeatureName:Microsoft-Windows-Subsystem-Linux
#  ->  Restart Windows to complete this operation.