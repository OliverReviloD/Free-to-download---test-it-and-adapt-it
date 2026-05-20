<#
    cls
    $DownloadedDrvFile = "C:\Users\JANEDO~1\AppData\Local\Temp\HPLJ1525nw_Driver\upd-pcl6-x64-6.4.1.22169.exe"
    $ExpandedDrvArchive = "C:\Users\JANEDO~1\AppData\Local\Temp\HPLJ1525nw_Driver\Expanded"
    Export-ZipFile_AllFiles -ZipFilePath $DownloadedDrvFile -ExportFolder $ExpandedDrvArchive
#>


# #############################################
# #############################################
Function Get-ZipFile_Content_as_Array {
    Param( [string]$ZipFilePath)  
    $IsAlreadyLoaded = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where { $_.ManifestModule -like 'System.IO.Compression.FileSystem*' }  
    if ( $IsAlreadyLoaded ) {
       # Write-Host "Assembly 'System.IO.Compression.FileSystem' already loaded"
        }
    else
        {
        Write-Host "Loading Assembly 'System.IO.Compression.FileSystem'"
        [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
        }
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipFilePath)
    $Content_as_Array  = $zip.Entries | Select FullName,Name
    $zip.Dispose()
    Return  $Content_as_Array 
    }

# #############################################
# #############################################
Function Export-ZipFile_SingleFile {
    Param( [string]$ZipFilePath,
           [string]$FullFileNameToExport,
           [string]$ExportFolder) 
    $FctName = "Export-ZipFile_SingleFile() - "

    if (!(test-path $ExportFolder)) 
        { 
        Write-Host "$FctName Creating new SubFolder '$ExportFolder'"
        $NewFolder = New-Item -path $ExpandedDrvArchive -ItemType Directory 
        }

    $IsAlreadyLoaded = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where { $_.ManifestModule -like 'System.IO.Compression.FileSystem*' }  
    #    $IsAlreadyLoaded.ManifestModule.Name 
    if ( $IsAlreadyLoaded ) {
       # Write-Host "$FctName Assembly 'System.IO.Compression.FileSystem' already loaded"
        }
    else
        {
        Write-Host "$FctName Loading Assembly 'System.IO.Compression.FileSystem'"
        [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
        }
   # Write-Host "$FctName Reading ZIP/Archive '$ZipFilePath'"
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipFilePath)
   # Write-Host "$FctName Searching for  '$FullFileNameToExport'"
    $DetectedFile = $zip.Entries | Where-Object FullName -eq $FullFileNameToExport 
    if ( $DetectedFile )
        {
        If ( $DetectedFile.Name -eq '' ) 
            { 
            # the ZIP-ENTRY contains only a folder structure ( which has to be created before Export )
            if ( $($DetectedFile.Fullname).endswith("\") -or $($DetectedFile.Fullname).endswith("/") )
                {
                $NewSubFolder = ($DetectedFile.Fullname).Substring(0, ($DetectedFile.Fullname).Length - 1)
                }
            else
                {
                $NewSubFolder = $DetectedFile.Fullname
                }
            $NewSubFolder = $NewSubFolder.Replace("/","\")
            if ( ! ( Test-Path "$ExportFolder\$NewSubFolder") )
                { 
                Write-Host "$FctName Creating new SubFolder '$ExportFolder\$NewSubFolder'"
                $NewFolder = New-Item -path "$ExportFolder\$NewSubFolder" -ItemType Directory 
                }
            }
        else
            {        
            $ExportPath = "$ExportFolder\" + $($DetectedFile.Fullname).Replace("/","\")
            $ExportSubFolder = Split-Path -parent $ExportPath
            if ( ! ( Test-Path $ExportSubFolder ) )
                { 
                Write-Host "$FctName Creating new SubFolder '$ExportSubFolder '"
                $NewFolder = New-Item -path $ExportSubFolder  -ItemType Directory 
                }

            Write-Host "$FctName '$($DetectedFile.Name)' - Export to - folder '$ExportSubFolder'"
            
            
            #  $zip.Entries | Where-Object FullName -eq $FullFileNameToExport | ForEach-Object{ Write-Host "$FctName '$($_.Name)'"; [System.IO.Compression.ZipFileExtensions]::ExportToFile($_, "$ExportFolder\$($_.Name)", $true) }
            $zip.Entries | Where-Object FullName -eq $FullFileNameToExport | ForEach-Object{ [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$ExportPath", $true) }
            $zip.Dispose() 
            Write-Host "$FctName '$($DetectedFile.Name)' - Export done"
            }
        }
    }


# #############################################
# PS1 - 'Expand-archive' full ZIP, all files   - this is not working with self-extracting EXE
#
#        Expand-archive -Path $DownloadedDrvFile -Destinationpath $ExpandedDrvArchive -Verbose
#
#      Self-Extracting-WinZip.Exe
# & myWinZipSelfExtract.exe -Info                          # =>  -win32 -i* -le -d* -overwrite -runasuser -c .\install.exe
# & myWinZipSelfExtract.exe /auto     C:\my-files\test
# & myWinZipSelfExtract.exe -unzipDir C:\my-files\test     # WinZIP UI will get displayed
# & $DownloadedDrvFile  /auto  $ExpandedDrvArchive         # Expand occurs, but Driver-Setup-GUI will get started 
# #############################################
Function Export-ZipFile_AllFiles {
    Param( [string]$ZipFilePath,
           [string]$ExportFolder) 
    $FctName = "Export-ZipFile_AllFiles() - "
    $FullFileName_FileName = Get-ZipFile_Content_as_Array -ZipFilePath $DownloadedDrvFile 
    ForEach($File in $FullFileName_FileName )
        {
        If ( $File.Name -eq '' ) {  
            # do nothing
            }
        else
            {
            $FullnameWithBackSlash = $($File.Fullname).Replace("/","\")
            Write-Host "$FctName '$($File.Name)' - Export to - '$ExpandedDrvArchive\$FullnameWithBackSlash'"
            Export-ZipFile_SingleFile -ZipFilePath  $DownloadedDrvFile -FullFileNameToExport $($File.Fullname) -ExportFolder $ExpandedDrvArchive
            }
        }
    }
