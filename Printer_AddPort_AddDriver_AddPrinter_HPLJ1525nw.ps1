#  Set-ExecutionPolicy Unrestricted -Scope Process
# Get-Printer
# Get-PrinterProperty -PrinterName ""
# Get-PrintJob -PrinterName ""
# Get-PrinterDriver


<#
    Block Redirection via Guest Group Policy (Permanent)
    
    To force printer redirection off inside the VM for all connections, you can use the Group Policy Editor:
    Start your Virtual Machine and log in.
    Press Win + R, type gpedit.msc, 
    Navigate to: 
        Computer Configuration > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Printer Redirection.
        
        Double-click 
            Do not allow client printer redirection.
            Set the policy to Enabled
            
    REBOOT required  ( gpupdate /force   is not sufficient ) 

#
# not working on  Win 11 25H2
#
    reg query   "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"  
    reg add     "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /f /t REG_DWORD  /v fDisableLPT  /d 1

#>


cls

Function Download-FromCloud
    {
    param( 
       [Parameter(Mandatory=$true)][string] $DownloadFolder,
       [Parameter(Mandatory=$true)][string] $CloudFileName,
       [Parameter(Mandatory=$true)][string] $CloudUrl)
       
    Write-Host "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"
    Write-Host "W  - verify download folder '$DownloadFolder' exists"
    Write-Host "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"
    if (!(test-path $DownloadFolder)) { 
        Write-Host "'$DownloadFolder' is missing - will be created"
        Try 
            {
            $NewFolder = new-item $DownloadFolder -ItemType Directory -force # -verbose 
            if (  test-path $DownloadFolder)  { Write-Host "'$DownloadFolder' is created" ; Write-host}
            }
        catch
            {
            if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
                {  
                # elevated
                }
            else
                {
                Write-Output "Elevation is required"
                Write-Output "ACCESS DENIED to create download folder '$DownloadFolder'"
                return 5
                }    
            if (!(test-path $DownloadFolder)) { Write-Host "'$DownloadFolder' cannot be created - EXIT 5" -ForegroundColor Red; Exit 5 }
            }   # END CATCH
        }  # END DownloadFolder does not exists
    if (  test-path $DownloadFolder)  { Write-Host "'$DownloadFolder' exists" ; Write-host}    
    
    $CloudFileDownloadedPath = "$DownloadFolder\$CloudFileName"
    Write-Host "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"
    Write-Host "W  - verify 'cloud file' exists at '$CloudFileDownloadedPath'  "
    Write-Host "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"
    if (!(Test-Path $CloudFileDownloadedPath)) {
        write-Host "Downloading from cloud '$CloudUrl'" -ForegroundColor Yellow
        write-Host "Downloading to         '$CloudFileDownloadedPath'" -ForegroundColor Yellow
        try {
           # $Response  = Invoke-WebRequest -Uri $CloudUrl -OutFile $CloudFileDownloadedPath -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer)  -Verbose
           # $StatusDescription = $Response.StatusDescription   # OKAY
           # $StatusCode        = $Response.StatusCode          # 200
            Invoke-WebRequest -Uri $CloudUrl -OutFile $CloudFileDownloadedPath -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer)  -Verbose # -Proxy $ProxyServer
            }
        catch [System.Net.WebException]
            {
            Write-Output "Ran into an issue: $($PSItem.ToString())"
            Write-Output "Unable to download .... from '$CloudFileDownloadedPath'"
            exit 1
            }
        catch [UnauthorizedAccessException]
            {
            Write-Output "Elevation is required"
            Write-Output "ACCESS DENIED to save to '$CloudFileDownloadedPath'"
            exit 5
            }
        catch 
            {
            $PSItem
            exit 5
            }
        }
    else { write-host "cloud file '$CloudFileDownloadedPath' already downloaded" }

    
    }
Function Main {

    $PortHostAddress = "192.168.0.190"
    $PortNumber      = "9100"
    $PortName        = "HPLJ1525nwPort:"
    
    $DownloadFolder  = "($Env:Temp)\HPLJ1525nw_Driver"
    $CloudFileName   = "HPLJ1525nw_Driver.ZIP"
    $CloudUrl        = "https://raw.githubusercontent.com/OliverReviloD/Free-to-download---test-it-and-adapt-it/refs/heads/main/HPLJ1525nw_Driver.ZIP"
     Download-FromCloud -DownloadFolder  $DownloadFolder  -CloudFileName  $CloudFileName -CloudUrl 
     return
    $DriverSourceDir = "D:\__B\Pri\Print\hpc1520u.inf_exported"
    $DriverINF       = "hpc1520u.inf"                                 # from HP download
    $DriverName      = "HP LaserJet Professional CP1520 Series PCL 6" # from HP download
    $PrinterLocation = "Wiesen32"
    $PrinterName     = "HP LaserJet 1525nw - local - $PrinterLocation"

    $PrinterPortSNMP = [PSCustomObject]@{     SNMPEnabled = $True;  SNMPCommunity = 'public';  SNMPIndex = 1}

   
return
    
    get-printer -name $PrinterName -ErrorAction SilentlyContinue  | FT | Out-string | Write-Host
    if ( Check-Elevation -eq $True) { Remove-MyPrinter       -PrinterName $PrinterName }
    Else                            { Write-Host "exiting 'Printer' will not get removed (elevation required) " -ForegroundColor Yellow }

    get-printerPort -name $PortName -ErrorAction SilentlyContinue  | FT | Out-string | Write-Host
    Remove-MyPrinterPort   -PortName $PortName 
    
  #  get-printerPort -name $PortName | select *

    get-printerDriver -name $DriverName -ErrorAction SilentlyContinue  | FT | Out-string | Write-Host
    if ( Check-Elevation -eq $True) { Remove-MyPrinterDriver -PrinterDriverName $DriverName }
    Else                            { Write-Host "exiting 'PrinterDriver' will not get removed (elevation required) " -ForegroundColor Yellow }
    #   return 0 
    
    AddChange-PrinterPort      -PortName $PortName -PortHostAddress $PortHostAddress -PortNumber $PortNumber -SNMPSettings $PrinterPortSNMP
   
    Add-PrinterDriver-Custom   -DriverSourceDir $DriverSourceDir  -DriverName $DriverName  -DriverINF $DriverINF



    $PrnInstalled = get-printer -name $PrinterName -ErrorAction SilentlyContinue 
    if ( $PrnInstalled  -eq $null ) {
        Write-host "Printer '$PrinterName'  will get installed" 
        Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName
        get-printer -name $PrinterName 
        }


    # Configuration   -   hpcp1520.cfg
    Write-host "`n`rPrinter will get configured" 
    Set-Printer -Name $PrinterName -Location $MyLocation -Priority 1
    Set-PrintConfiguration -PrinterName $PrinterName -PaperSize A4 -Color $False -Collate $False -DuplexingMode OneSided

    #   or   export, modify and re-import
    # $PrintConfiguration = Get-PrintConfiguration -PrinterName "Microsoft XPS Document Writer"
    # $PrintConfiguration.paperSize = A4
    # Set-PrintConfiguration -InputObject $PrintConfiguration

    Write-host "`n`rPrinter $PrinterName" 
    get-printer -name $PrinterName | format-list | Out-String | Write-Host
    Write-host "`n`rPrintConfiguration" 
    Get-PrintConfiguration -PrinterName $PrinterName | format-list  | Out-String | Write-Host


    # ###############################################################
    #
    #     Only for current User
    #
    #

    #   Windows-Settings - "Windows Manages Printers" = Disabled
    # reg.exe add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /f /t REG_DWORD /v LegacyDefaultPrinterMode  /d 1
    #
    Write-host "`n`rWindows-Settings - 'Windows Manages Printers' = Disabled  - only for current user" 
    $RegAddREsult = reg.exe add 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows' /f /t REG_DWORD /v LegacyDefaultPrinterMode  /d 1

    Write-host "`n`rWindows-Settings - '$PrinterName' - 'SetDefaultPrinter'" 
    $WmiResult = (Get-WMIObject -ClassName win32_printer | Where-Object -Property Name -eq $PrinterName).SetDefaultPrinter()


    <#

        Disable Windows-Manages-Printers

        set RegHive=HKLM\TempHive
        reg load %RegHive% C:\users\Default\NtUser.Dat
        reg add "%RegHive%\Software\Microsoft\Windows NT\CurrentVersion\Windows" /f /t REG_DWORD /v LegacyDefaultPrinterMode  /d 1
        reg unload %RegHive%
    #>

    return 0

    }


# elevation may be required to run some of the following commands
Function Check-Elevation()  
    {       
    if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
         { Write-host "Script is started:   Elevated."    ;  return $True     } 
    else { Write-host "Script is started:   Not elevated" ;  return $False    }
    }

Function Remove-MyPrinter
    {
    param( [Parameter(Mandatory=$true)][string] $PrinterName)

    $PrnInstalled = get-printer -name $PrinterName -ErrorAction SilentlyContinue 
    if ( $PrnInstalled  -ne $null ) {
        Write-host "Printer '$PrinterName' will get removed" 
        remove-Printer -Name $PrinterName 
        }
    $PrnInstalled = get-printer -name $PrinterName -ErrorAction SilentlyContinue 
    if ( $PrnInstalled  -eq $null ) {
        Write-host "Printer '$PrinterName' is removed or does not exist" -ForegroundColor Green
        }
    else
        {
        Write-host "Printer '$PrinterName' could not get removed" -ForegroundColor RED
        Write-host "Remaining Printers" -ForegroundColor Green
        get-printer |  FT -autoSize  | Out-String | Write-Host
        Exit 9999
        }
    Write-host "Remaining Printers" -ForegroundColor Green
    get-printer |  FT -autoSize  | Out-String | Write-Host
    }

Function Remove-MyPrinterPort
    {
    param( [Parameter(Mandatory=$true)][string] $PortName)

    $PortExists = get-printerport | Where-object { $_.Name -eq $PortName }
    If ( $PortExists  -ne $null ) {
        Write-host "`r`nPrinterport '$PortName' already exists - $($PortExists.PrinterHostAddress) - $($PortExists.Description)" 

        # check if other printers are connected to this port
        $PortRequiredByOtherPrinters = get-printer | Where-object { $_.PortName -eq $PortName }
        if (  $PortRequiredByOtherPrinters  -eq $Null )
            {
            Write-host "No other printers are associated to this port - printerport '$PortName' will be removed" 
            Remove-PrinterPort -Name $PortName -verbose
            }
        else
            {
            Write-host "Other printers are associated to this port - printerport '$PortName' will NOT get removed" -ForegroundColor Red
            Exit 9997
            }
        }
    $PortExists = get-printerport | Where-object { $_.Name -eq $PortName }
    if ( $PortExists  -eq $null ) {
        Write-host "PrinterPort '$PortName' is removed or does not exist" -ForegroundColor Green
        }
    else
        {
        Write-host "PrinterPort '$PortName' could not get removed" -ForegroundColor RED
        get-printerport |  FT -autoSize  | Out-String | Write-Host
        Exit 9998
        }
    Write-host "Remaining PrinterPorts" -ForegroundColor Green
    get-printerport |  FT -autoSize | Out-String | Write-Host
    }

Function Remove-MyPrinterDriver
    {
    param( [Parameter(Mandatory=$true)][string] $PrinterDriverName)

    $DriverExists = get-PrinterDriver | Where-object { $_.Name -eq $PrinterDriverName }
    If ( $DriverExists  -ne $null ) {
        $DriverExists |  FT -autoSize  | Out-String | Write-Host     #  | select * 

        Write-host "`r`PrinterDriver '$PrinterDriverName' already exists - $($PrinterDriver.Manufacturer) " 
        Write-host "PrinterDriver '$PrinterDriverName' will be removed" 
        Remove-PrinterDriver -Name $PrinterDriverName -verbose
        }
    
    $DriverExists = get-PrinterDriver | Where-object { $_.Name -eq $PrinterDriverName }
    if ( $DriverExists  -eq $null ) {
        Write-host "PrinterDriver '$PrinterDriverName' is removed or does not exist" -ForegroundColor Green
        }
    else
        {
        Write-host "PrinterDriver '$PrinterDriverName' could not get removed" -ForegroundColor RED
        Write-host "Remaining PrinterDrivers" -ForegroundColor Green
        get-PrinterDriver |  FT -autoSize  | Out-String | Write-Host
        Exit 9999
        }
    Write-host "Remaining PrinterDriver" -ForegroundColor Green
    Get-PrinterDriver | FT -autoSize  | Out-String | Write-Host
    }

Function AddChange-PrinterPort 
    {
    param( 
       [Parameter(Mandatory=$true)][string] $PortName,
       [Parameter(Mandatory=$true)][string] $PortHostAddress,
       [Parameter(Mandatory=$true)][string] $PortNumber,
       [Parameter(Mandatory=$true)][PSCustomObject] $SNMPSettings)

    $IsElevated = Check-Elevation
    Write-host "`r`n  XXXXXXXXXXXXXXXX    AddChange-PrinterPort   XXXXXXXXXXXXXXXXXXXXXXXX" 
    Write-host "`r`n current PrinterPorts" 
    get-printerport | FT | Out-String | Write-Host


    $PortExists = get-printerport | Where-object { $_.Name -eq $PortName }
    If ( $PortExists  -ne $null ) {
        Write-host "`r`nPrinterport '$PortName' already exists - $($PortExists.PrinterHostAddress) - $($PortExists.Description)" 

        if ( $PortExists.PrinterHostAddress -ne $PortHostAddress ) 
            {
            Write-host "Printerport '$PortName' already exists - but has wrong/old IP-Address"

            # collect all assigned printers , remove old port, create new port and assign new port to printer(s)
            $AllPrintersPortAlreadyUsed = Get-Printer  | Where { $_.PortName -eq $PortName }
        
            Write-host "Printerport '$PortName' will be removed" 
            Remove-PrinterPort -Name $PortName -verbose
        
            Write-host "Printerport '$PortName' will be re-added with new IP - '$PortHostAddress'"
            
             if ( $SNMPSettings.SNMPEnabled -eq $True ) 
                  #  $SNMPSettings.SNMPEnabled 
                  #  $SNMPSettings.SNMPCommunity 
                  #  $SNMPSettings.SNMPIndex
                {    
                Add-PrinterPort -Name $PortName -printerhostaddress $PortHostAddress  -PortNumber $PortNumber -SNMPEnabled  $SNMPSettings.SNMPEnabled  -SNMPCommunity $SNMPSettings.SNMPCommunity 
                }
            else
                {
                Add-PrinterPort -Name $PortName -printerhostaddress $PortHostAddress  -PortNumber $PortNumber 
                }
            ForEach( $p in $AllPrintersPortAlreadyUsed) { Write-host "changed Printerport '$PortName' will be assigned to '$p.Name'" ; Set-Printer -name $p -PortName $PortName }
            }
        }
    else
        {
        Write-host "`r`nPrinterport '$PortName' will be added - '$PortHostAddress' - '$PortNumber'" 
       # if ( $IsElevated -eq $True ) {
             if ( $SNMPSettings.SNMPEnabled -eq $True ) 
                  #  $SNMPSettings.SNMPEnabled 
                  #  $SNMPSettings.SNMPCommunity 
                  #  $SNMPSettings.SNMPIndex
                {    
                Add-PrinterPort -Name $PortName -printerhostaddress $PortHostAddress  -PortNumber $PortNumber  -SNMPCommunity $SNMPSettings.SNMPCommunity   -SNMP $SNMPSettings.SNMPIndex 
                }
            else
                {
                Add-PrinterPort -Name $PortName -printerhostaddress $PortHostAddress  -PortNumber $PortNumber 
                }
            $PortExists = get-printerport | Where-object { $_.Name -eq $PortName }
            Write-host "Printerport '$PortName' added - $($PortExists.PrinterHostAddress) - $($PortExists.Description)" 
        #    }
        #else 
        #    { 
        #    Write-Error "ERROR - elevation required - EXIT 5" -Category PermissionDenied 
        #    Exit 5 
        #    }
        }

    get-printerport | Where-object { $_.Name -eq $PortName } | format-list
    
    }

Function Add-PrinterDriver-Custom 
    {
    param( 
       [Parameter(Mandatory=$true)][string] $DriverSourceDir,
       [Parameter(Mandatory=$true)][string] $DriverName,
       [Parameter(Mandatory=$true)][string] $DriverINF)
    Write-host "`r`n  XXXXXXXXXXXXXXXX    AddChange-PrinterPort   XXXXXXXXXXXXXXXXXXXXXXXX" 
    
    $IsElevated = Check-Elevation
    

    Write-host "`r`nenum installed printer drivers - ALL" 
    Write-host " ============================================="
    
    $PnPDriverIsInstalled= get-printerdriver -name *   # | where-object { $_.Manufacturer -eq "HP" } 
    $PnPDriverIsInstalled | format-Table

    if (  $Null -ne $PnPDriverIsInstalled  ) {
        Write-host "`r`nenum installed 'HP' (Hewlett Packard) printer drivers" 
        Write-host " ============================================="
        $PnPDriverIsInstalled= get-printerdriver -name * | where-object { $_.Manufacturer -eq "HP" } 
        $PnPDriverIsInstalled | format-Table
        
    
        if ( $Null -ne $PnPDriverIsInstalled )             {
            Write-host "`r`nenum installed 'HP' - '$DriverName' printer driver" 
            Write-host " ============================================="
            $PnPDriverIsInstalled= get-printerdriver -name * | where-object { ($_.Manufacturer -eq "HP") -and ($_.Name -eq $DriverName) } 
            $PnPDriverIsInstalled | format-List
            # $PnPDriverIsInstalled.DependentFiles
 
            $ver = $PnPDriverIsInstalled.DriverVersion
            $VersString= (3..0 | ForEach-Object { ($ver -shr ($_ * 16)) -band 0xffff }) -join '.'
            Write-host "DriverVersion           :$VersString`r`n`r`n"     #   well known numbering -   version 61.103.21.8726
                

            if (  $Null -ne $PnPDriverIsInstalled  )            {
                Write-host "`r`Printer-Driver is already installed - EXIT 0"
                return 0 
                }
            else
                {
                Write-host "`r`nNo 'HP' - '$DriverName' printer driver PrinterDrive is installed"
                }
            }
        else
            {
            Write-host "`r`nNo 'HP' printer driver(s) are installed"
            }
        }
    else
        { 
        Write-host "`r`nNo printer driver(s) are installed"
        } 


    # ####################################################################
    # ####################################################################
    # ####################################################################
    Write-host "`r`n ============================================="
    Write-host "'$DriverSourceDir' - check if file or folder" 
    
    $SourceFile   = $Null
    $SourceFolder = $Null

    if (Test-Path -Path $DriverSourceDir -PathType Container )  { $SourceFolder = Get-Item $DriverSourceDir }
    if (Test-Path -Path $DriverSourceDir -PathType Leaf )       { $SourceFile   = Get-Item $DriverSourceDir }

    if ( ( $SourceFolder -eq $Null ) -and ($SourceFile -eq $Null ))  {
        Write-host "'$DriverSourceDir' - not a folder or does not exists"
        Write-host "'$DriverSourceDir' - not a file   or does not exists"
        return 1 }
    elseif  ( $SourceFolder -ne $Null ) { Write-host "`r`n'$DriverSourceDir' - folder exists" }
    elseif  ( $SourceFile   -ne $Null ) { Write-host "`r`n'$DriverSourceDir' - file   exists" }
    else                                { Write-host "`r`n'$DriverSourceDir' - Warning - script is using Source as 'folder'-object - please check the result"; $SourceFile = $Null }
    

    # ####################################################################
    $LocalSourcePath = "$Env:Temp\Driver_Setup_Files_PS1"
    Write-host "`r`nprepare TARGETDIR '$LocalSourcePath' for copy " 
    Write-host "--- '$LocalSourcePath' - check existence of copy-folder-target" 
    if ( ! ( test-path $LocalSourcePath) ) { 
        Write-host  "--- '$LocalSourcePath' - missing -> will be created now"
        New-Item -ItemType directory -Path $LocalSourcePath | out-null
    } else {
        Write-host "--- '$LocalSourcePath' - already exists"
        }

    # ####################################################################
    if ( $SourceFolder -ne $Null ) {
        #
        Write-host "`r`n'$DriverSourceDir' - copy folder to '$LocalSourcePath' - prevent network related INF issues"
        Copy-Item $DriverSourceDir $LocalSourcePath -Recurse -force
        $CopiedFolder = ($DriverSourceDir.split("\"))[-1]
        $LocalSourcePath  = $LocalSourcePath  + "\$CopiedFolder"
        Write-host "--- copy done to LocalSourcePath='$LocalSourcePath'"
        }

    # ####################################################################
    Write-host "`r`n'SourceFile'='$SourceFile'"
    if ( $SourceFile -eq $Null -or $SourceFile -eq ''  ) 
        {
        $SourceFile = $LocalSourcePath  + "\"  + $DriverINF    #
        }
    
    Write-host "`r`n'SourceFile'='$SourceFile'"
    
    if ( $SourceFile -ne $Null -and $SourceFile -ne ''  ) 
        {
        $LocalFileName = $SourceFile
         Write-host "`r`n'LocalFileName'='$LocalFileName'"
        if (test-Path $LocalFileName) {
            Write-host "`r`n'$LocalFileName' - file already exists - no copy required"
            }
        else
            {
            Copy-item $SourceFile $LocalFileName 
            if ( test-Path $LocalFileName) { Write-host "`r`n'$LocalFileName' - file copied" }
            else                           { Write-host "`r`n'$LocalFileName' - copy failed - EXIT 1"; return 1 }
            }

        <#
                if (test-Path $LocalFileName) {
                    Write-host "`r`n ============================================="
                    Write-host "expand starts" 
                    Expand -R*.*  $LocalFileName $($LocalSourcePath + "\")
                    }
                #>
        }


    
    
    # ####################################################################
    #
    #   INF based driver needs to be installed
    #
    Write-host "`r`n ============ INF based driver needs to be installed ================================="
    if ( $PnPDriverIsInstalled  -eq $null ) {
        Write-Host "Elevation granted = '$IsElevated'"
        if ( $IsElevated -ne $True ) {
            Write-error  "Elevation required - 'Access is denied'" -Category PermissionDenied
            exit 5
            }

       # $PnpUtilParameters =  " /enum-drivers"
       # & "C:\Windows\system32\PnpUtil.exe" $PnpUtilParameters.split(" ") 
       # return 0

        If ( ! (test-path $LocalSourcePath) ) {
            Write-error  "folder '$LocalSourcePath' is missing" -Category InvalidData
            return 1
            }

        If ( ! (test-path ("$LocalSourcePath\$DriverINF") ) ) {
            Write-error  "'$DriverINF' missing at '$LocalSourcePath'" -Category InvalidData
            return 1
            }



        #  Add-WindowsDriver = Online for Offline-Images
        #   
        #   PnpUtil will only ADD the printer driver to the driver store
        #
        #   elevation required
        Write-host "`r`n ============================================="
        $PnpUtilParameters =  " /add-driver ""$LocalSourcePath\$DriverINF"" /install "
        Write-host "starting external process - PnpUtil.exe $PnpUtilParameters" 
        & "C:\Windows\system32\PnpUtil.exe" $PnpUtilParameters.split(" ")
        Write-host "LastExitcode ='$LastExitcode'"
        if ($LastExitcode -eq 2 ) {
            Write-error  "DRV installation failed - 'The system cannot find the file specified.'" -Category PermissionDenied
            return 2
            }

        if ($LastExitcode -eq 5 ) {
            Write-error  "Elevation required - 'Access is denied'" -Category PermissionDenied
            return 5
            }

        if ($LastExitcode -eq "-536870325" ) {
            Write-error  "Invalid driver signature" -Category PermissionDenied
            return 998
            }
    
        if ( $LastExitcode -ne "0" ) { 
            Write-error  "DRV installation failed - PnpUtil.exe returned '$LastExitcode'" -Category InvalidData
            return 999
            }
    
        #   
        #   PowerShell "Add-PrinterDriver -name.."  will ADD the printer driver from local driver store to local printer Mgnt
        #
 
        $LocalINF = "$LocalSourcePath\$DriverINF"
        Write-host "PrinterDriver will get installed from $LocalINF" 
        Add-PrinterDriver  -name $DriverName # -InfPath $LocalINF 
    
    
        
        #  Notepad.exe "$Env:windir\inf\setupapi.dev.log"
        
        # maybe some more manual configuration ??
        # copy-item "$DriverDir\hpcp1520.cfm"  "C:\WINDOWS\system32\spool\DRIVERS\x64\3\hpcp1520.cfm" -Force
        # copy-item "$DriverDir\hpcp1520.cfg"  "C:\WINDOWS\system32\spool\DRIVERS\x64\3\hpcp1520.cfg" -Force

        # C:\WINDOWS\system32\spool\DRIVERS\x64\3\hpc1520u.ini
        
        
        }   # END-IF     if driver does not exist on local client

    


    # ####################################################################
    #
    #   INF based driver should now be installed  - or has been already installed before 
    #

    if ( $PnPDriverIsInstalled  -eq $null ) {
        Write-host "re-enum installed HP printer driver '$DriverName'" 
        $PnPDriverIsInstalled= get-printerdriver -name * | where-object { $_.Manufacturer -eq "HP" -and $_.Name -eq $DriverName } 
        $PnPDriverIsInstalled | format-list
        
         If ( test-path ("$LocalSourcePath\$DriverINF" ) ) {
            Write-host "`r`nCleanup after Add-PrinterDriver() - remove folder '$LocalSourcePath'"
            remove-Item $LocalSourcePath -force -Recurse -verbose | out-Null
            }


        Write-host "PrinterDriver '$DriverName' is (now / already)  installed" 
        }
 
    }



return Main

