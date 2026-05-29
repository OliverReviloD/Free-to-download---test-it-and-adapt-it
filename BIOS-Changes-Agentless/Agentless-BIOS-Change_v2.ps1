
#
#   powershell prevents to run if not started via "Run as administrator" = elevated
#
#Requires -Runasadmin
#

# Set-ExecutionPolicy Unrestricted -Scope Process

<#
    Return Values
        90       'Get-CimInstance -Namespace ...\wmisecurity...' is not supported ( e.g. too old HW or too old OS)

        91       Either:   option '$BiosOptionName' is NOT supported on this motherboard / hardware
        91       Or:       option '$BiosOptionName' is NOT supported by native MS WMI/CIM
        
        92       Option '$BiosOptionName' does not support the new value '$BiosOptionValueDesired' ( on this HW model or with installed BIOS )   

        0        Either:  Option '$BiosOptionName' is already set to '$BiosOptionValueDesired'
        0        Or:      Changes done successfully     

        1        '$BiosOptionName' change to '$BiosOptionValueDesired' failed

        3        BIOS PWD is set, but BIOS-PWD in script does not match

        5
        
        3010     REBOOT desired to process changes
#>



cls   
$BiosPwdDefault                  = "Dell1234"      # current BIOS pwd in clear text - if required    "CurrentTopSecretBiosPwd1!"   or "Dell1234"   or ....
                                                                   # "C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe" --SetupPwd="CurrentTopSecretBiosPwd1!"
                                                                   # "C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe" --SetupPwd=Dell1234!                   --ValSetupPwd="CurrentTopSecretBiosPwd1!"
                                                                   # "C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe" --SetupPwd=                            --ValSetupPwd="Dell1234"
$BiosOptionName                  = "CapsuleFirmwareUpdate"
$BiosOptionValueDesired          = "Enabled"                      # "Disabled"  "Enabled"   or ....
  
Write-Host "################## desired config ##################"
Write-Host "BiosOptionName                  = '$BiosOptionName'"  
Write-Host "BiosOptionValueDesired          = '$BiosOptionValueDesired'"



# ###################################################
# run inventory
# ###################################################
$BiosInfo       = Get-CimInstance -Class win32_Bios    
$BiosVersion    = $BiosInfo.SMBIOSBIOSVersion
$BiosServiceTag = $BiosInfo.SerialNumber
$HwManufacturer = $BiosInfo.Manufacturer
$HwModel        = (Get-CimInstance -Class win32_ComputerSystem | select Model).Model
Write-Host "##################### inventory ####################"
Write-Host "HwManufacturer                  = '$HwManufacturer'"   #  Manufacturer      : Dell Inc.      'Microsoft Corporation'
Write-Host "HwModel                         = '$HwModel'"          #  Model             : Latitude 5410  Virtual Machine
Write-Host "BiosServiceTag                  = '$BiosServiceTag'"   #  SerialNumber      : DPWS...        2006-2818-3542-7.....
Write-Host "BiosVersion                     = '$BiosVersion'"      #  SMBIOSBIOSVersion : 1.40.1         Hyper-V UEFI Release v4.1



# ###################################################
# ###################################################
# these variables will be set by this script
$BiosOptionValueCurrent          = $Null     # $Null = unknown, else current value returned by 'Get-CimInstance ....'
$BiosOptionValueChangeRequired   = $Null     # $Null = unknown, else $True or $False
$BiosOptionValuePossible         = $Null     # $Null = unknown, else current value returned by 'Get-CimInstance ....'   e.g. Disabled, Enabled
$BiosOptionValueDesiredSupported = $Null     # $Null = unknown, else $True or $False
$BiosPwdIsSet                    = $Null     # $Null = unknown (unsupported?), else $True or $False

    Write-Host "############### Query Is-Bios-Pwd-Set ###############"
    $PasswordCheck = Get-CimInstance -Namespace root\dcim\sysman\wmisecurity -ClassName PasswordObject  -ErrorAction SilentlyContinue 
    $PasswordCheck = $PasswordCheck | Where-Object NameId -EQ "Admin" | Select-Object -ExpandProperty IsPasswordSet

    if ($PasswordCheck  -eq $Null ) # ->   not supported, e.g. Hyper-V client
        {
        Write-Host "No change of Bios option '$BiosOptionName' will get done"                     -ForegroundColor RED
        If ( $HwModel -eq 'Virtual Machine' -and $HwManufacturer -eq 'Microsoft Corporation' )  
            {  
            Write-Host "MS Hyper-V Clients are not supported by this script"     -ForegroundColor RED
            }
        else
            { 
            Write-Host "'Get-CimInstance -Namespace ...\wmisecurity...' is not supported ( e.g. too old HW or too old OS)" -ForegroundColor RED
            }
        Write-Host " - Exit 90" -ForegroundColor RED
        Return 90
        }
    elseif ( $PasswordCheck -eq 0 )  { $BiosPwdIsSet = $False } # 0    ->   BIOS Admin PWD is NOT set
    elseif ( $PasswordCheck -eq 1 )  { $BiosPwdIsSet = $True  } # 1    ->   BIOS Admin PWD is     set

Write-Host "BiosPwdIsSet                    = '$BiosPwdIsSet'" 

# ###################################################
# "checking existence of '$BiosOptionName' and if desired value '$BiosOptionValueDesired' is a valid value"
# ###################################################

    Write-Host "############# Query Existing-Settings #############"
    $Enumeration = Get-CimInstance -Namespace root\dcim\sysman\biosattributes -ClassName EnumerationAttribute | Select "AttributeName","CurrentValue","PossibleValue"
    $CurrentConfig = $Enumeration | Where-Object AttributeName -eq $BiosOptionName | Select-Object AttributeName,CurrentValue,PossibleValue

    if ( $CurrentConfig -eq $NULL )
        {
        Write-Host "No change of Bios option '$BiosOptionName' will get done" -ForegroundColor RED
        Write-Host "Either:   option '$BiosOptionName' is NOT supported on this motherboard / hardware" -ForegroundColor RED
        Write-Host "Or:       option '$BiosOptionName' is NOT supported by native MS WMI/CIM" -ForegroundColor RED
        Write-Host " - Exit 91" -ForegroundColor RED
        Return 91
        }
    [String]$S1 = $CurrentConfig | out-string 
    write-host $S1.Substring(0, $S1.Length -2) 
    $BiosOptionValueCurrent          = $CurrentConfig.CurrentValue
    $BiosOptionValuePossible         = $CurrentConfig.PossibleValue -Join ","


Write-Host "BiosOptionValueCurrent          = $("'$BiosOptionValueCurrent'".Padright(18," "))    Null = unknown"  
Write-Host "BiosOptionValuePossible         = $("'$BiosOptionValuePossible'".Padright(18," "))    Null = unknown"  

if ( $BiosOptionValueCurrent -eq $BiosOptionValueDesired )
    {
    $BiosOptionValueChangeRequired   = $False
    $BiosOptionValueDesiredSupported = $True
    }
else
    {
    $BiosOptionValueChangeRequired   = $True

    # ##### does this HW support the "desired" value ? ##################
    If ( $BiosOptionValueChangeRequired  -eq $True )
        {
        if ( $CurrentConfig.PossibleValue -contains $BiosOptionValueDesired  )   
            {
            $BiosOptionValueDesiredSupported = $True
            }
        else
            {
            $BiosOptionValueDesiredSupported = $False
            }
        }
    }

Write-Host "###################################################"
Write-Host "BiosOptionValueChangeRequired   = $("'$BiosOptionValueChangeRequired'".Padright(18," "))    Null = unknown"  
Write-Host "BiosOptionValueDesiredSupported = $("'$BiosOptionValueDesiredSupported'".Padright(18," "))    Null = unknown"  
 

if ( $BiosOptionValueChangeRequired -eq $false )
    {
    Write-Host "No change of Bios option '$BiosOptionName' is required"               -ForegroundColor Green
    Write-Host "Option '$BiosOptionName' is already set to '$BiosOptionValueDesired'" -ForegroundColor Green
    Write-Host " - Exit 0"                                                            -ForegroundColor Green
    Return 0
    }

if ( $BiosOptionValueDesiredSupported -eq $false )
    {
    $CurrentConfig | out-string | write-host -ForegroundColor RED
    Write-Host "No change of Bios option '$BiosOptionName' will get done"                              -ForegroundColor RED
    Write-Host "Option '$BiosOptionName' does not support the new value '$BiosOptionValueDesired'"     -ForegroundColor RED
    Write-Host " - on this HW model or with installed BIOS "                                           -ForegroundColor RED
    Write-Host " - Exit 92"                                                                            -ForegroundColor RED
    Return 92
    }

# ###################################################
# ###################################################
if (  $BiosPwdIsSet  -eq $True )
    {
    Write-Host "###################################################"
    Write-Host "Change BIOS Settings - With  Password"
    $BIOSAttributeInterface = Get-CimInstance -Namespace root\dcim\sysman\biosattributes -Class BIOSAttributeInterface
    # $BIOSAttributeInterface | Get-Member

    $Encoder       = New-Object System.Text.UTF8Encoding
    $SetupPwdBytes = $encoder.GetBytes($BiosPwdDefault)    #encode the password

    $argumentsWithPWD = @{ AttributeName=$BiosOptionName; 
                           AttributeValue=$BiosOptionValueDesired; 
                           SecType=1; 
                           SecHndCount=$SetupPwdBytes.Length; 
                           SecHandle=$SetupPwdBytes     }
    $SetResult     = Invoke-CimMethod -InputObject $BIOSAttributeInterface    -MethodName SetAttribute -Arguments   $argumentsWithPWD        #  -ErrorAction Stop

    Write-Host "Change of Bios option '$BiosOptionName' to '$BiosOptionValueDesired' with a BIOS PWD`r`n - returned Status=$($SetResult.Status) and ReturnValue=$($SetResult.ReturnValue) " 
    if ( $SetResult.Status -eq 0 )
        {
        #
        #   if no BIOS pwd is set, but "Invoke-CimMethod ..." contains a PWD, then "Invoke-CimMethod ..." does not raise an error - although nothing gets changed in BIOS
        #
        #   re-query current value
        #
        Write-Host "`r`n...query new value after change..."
        $Enumeration = Get-CimInstance -Namespace root\dcim\sysman\biosattributes -ClassName EnumerationAttribute | Select "AttributeName","CurrentValue","PossibleValue"
        $CurrentConfig = $Enumeration | Where-Object AttributeName -eq $BiosOptionName | Select-Object AttributeName,CurrentValue,PossibleValue
        $CurrentConfig | out-string | write-host
        $BiosOptionValueCurrent          = $CurrentConfig.CurrentValue
        if ( $BiosOptionValueDesired -eq $BiosOptionValueCurrent )
            {
            Write-Host "'$BiosOptionName' is set to '$BiosOptionValueDesired'" -ForegroundColor Green
            Write-Host " - Exit 3010 - REBOOT desired to process changes" -ForegroundColor Green
            Return 3010
            }
        else
            {
            Write-Host "'$BiosOptionName' change  with a BIOS PWD -  to '$BiosOptionValueDesired' failed" -ForegroundColor red
            Write-Host " - a different BIOS password (SetupPwd) or NO password seems to be set"           -ForegroundColor red
            Write-Host " - Exit 3"                                                                        -ForegroundColor red
            Return 3
            }
        }
    elseif ( $SetResult.Status -eq 3 )
        {
        # this is verified
        Write-Host "'$BiosOptionName' change to '$BiosOptionValueDesired' failed"                                   -ForegroundColor red
        Write-Host " - a different BIOS password (SetupPwd) seems to be set than defind in this script (verified: SetResult-Status=3)" -ForegroundColor red
        Write-Host " - Exit 3"                                                                                       -ForegroundColor red
        Return 3
        }  
    else
        {
        # this is an assumption only :-(   - more testing is required
        Write-Host "'$BiosOptionName' change to '$BiosOptionValueDesired' failed"                                    -ForegroundColor red
        Write-Host " - a different BIOS password (SetupPwd) seems to be set than defind in this script (assumption)" -ForegroundColor red
        Write-Host " - SetResult-Status = $($SetResult.Status)"                                                      -ForegroundColor red
        Write-Host " - Exit 99"                                                                                      -ForegroundColor red
        Return 99
        }    
    }

# ###################################################
# ###################################################
if ( $BiosPwdIsSet  -eq $false )
    {
    Write-Host "###################################################"
    Write-Host "Change BIOS Settings - Without Password"
    $BIOSAttributeInterface = Get-CimInstance -Namespace root\dcim\sysman\biosattributes -Class BIOSAttributeInterface
    $argumentsNoPWD = @{ AttributeName=$BiosOptionName; 
                         AttributeValue=$BiosOptionValueDesired; 
                         SecType=0;
                         SecHndCount=0;
                         SecHandle=@()}  

    # 2026-May .... not working anymore ?  -PS1 error "Method invocation failed because [Microsoft.Management.Infrastructure.CimInstance] does not contain a method named 'SetAttribute'."
    # $BIOSAttributeInterface.SetAttribute(0,0,0,$BiosOptionName,$BiosOptionValueDesired)

    $SetResult = Invoke-CimMethod -InputObject $BIOSAttributeInterface  -MethodName SetAttribute `
                                  -Arguments   $argumentsNoPWD          -ErrorAction Stop

    $SetResult  | select * | out-string | write-host
        <#
            Status ReturnValue PSComputerName
            ------ ----------- --------------
                 0        True               

        #>
    Write-Host "Change of Bios option '$BiosOptionName' to '$BiosOptionValueDesired' without a BIOS PWD `r`n- returned Status=$($SetResult.Status) and ReturnValue=$($SetResult.ReturnValue) " 
    if ( $SetResult.Status -eq 0 )
        {
        Write-Host "'$BiosOptionName' is set to '$BiosOptionValueDesired'" -ForegroundColor Green
        Write-Host "Exit 3010 - REBOOT desired to process changes" -ForegroundColor Green
        Return 3010
        }
    else
        {
        Write-Host "'$BiosOptionName' change to '$BiosOptionValueDesired' failed" -ForegroundColor RED
        Write-Host " - a BIOS password (SetupPwd) seems to be set"                -ForegroundColor RED
        Write-Host " - Exit 1"                                                    -ForegroundColor RED
        Return 1
        }    
    }


