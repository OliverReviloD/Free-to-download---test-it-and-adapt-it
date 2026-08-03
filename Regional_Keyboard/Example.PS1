# Set-ExecutionPolicy Unrestricted -Scope Process

# HKEY_USERS\.DEFAULT\Control Panel\International\User Profile System Backup\en-US


#Requires -RunAsAdministrator
clear-Host

if($env:SESSIONNAME -eq 'Console')
    {
    Write-Host "You are running on the local machine."  -ForegroundColor Green
    }
else
    {
    Write-Host     "You are in a Remote desktop session ('$env:SESSIONNAME')." -ForegroundColor Yellow
    Write-Warning  "This script session is started via RDP - the script results ( especially VM-/RDP-Login-Screens ) may be impacted by the regional settings of your local PC" -ForegroundColor Yellow
    Write-Host     "You should test your script always on a physical computer - no RDP, no VM." -ForegroundColor Yellow
    }



$InstalledLanguages = $Null


$SystemUILanguage                   = Get-SystemLanguage              # ->  en-US
$SystemPreferredLanguage            = Get-SystemPreferredUILanguage   # ->  en-US

[String]$PreferredUILanguage          =    "en-US"
[String]$PreferredKeyBoardLanguage    =    "de-DE"
[String]$PreferredKeyBoardLanguageID  =    "0407"

# [String]$PreferredKeyBoardLanguage    =    "en-US"
# [String]$PreferredKeyBoardLanguageID  =    "0409"



[Array]$RemoveLanguages           =    "en-GB"

if ( $InstalledLanguages -eq $Null )
    {
    Write-Host "`r`nQuery existing LanguagePacks"

    # Get-InstalledLanguage -language $PreferredKeyBoardLanguage   
    # $InstalledLanguages = Get-InstalledLanguage 
    # $InstalledLanguages | select *        #  =>   LanguageID

    #  This command will show the language features that are installed for the en-US language.
    $PreferredLanguageInstalled =  Get-InstalledLanguage -Language $PreferredUILanguage 
        <#
            Language Language Packs  Language Features                                                     
            -------- --------------  ----------------- 
            de-DE    LpCab           BasicTyping, Handwriting, Speech, TextToSpeech, OCR                                                         
            en-GB    None            BasicTyping, OCR                                                      
            en-US    LpCab           BasicTyping, Handwriting, Speech, TextToSpeech, OCR                   
        #>
    
    
    if ( $PreferredLanguageInstalled  ) 
        {
        Write-Host "Preferred language '$PreferredLanguage' is already installed ( LanguagePack )"
        }
    else
        {
        # install the required language pack
        Write-Host "Preferred language '$PreferredLanguage' needs to get installed ( Add LanguagePack )"
        <#
            #Requires -RunAsAdministrator
        #>
        Install-Language -Language $PreferredKeyBoardLanguage-CopyToSettings -ErrorAction Stop
        $InstalledLanguages = Get-Language 
        $InstalledLanguages
        }

    if ( $SystemUILanguage -ne $PreferredUILanguage ) 
        { 
        Write-Host "Switching from UI-Lang 'SystemUILanguage' to '$PreferredUILanguage'"
        Set-SystemLanguage $PreferredUILanguage 
        }


    # remove not desired  LanguagePacks
    $InstalledLanguages = Get-InstalledLanguage 
   if ($InstalledLanguages.Count -gt 1 -and $RemoveLanguages -notcontains  $PreferredLanguage)
        {
        ForEach ( $Lang in $RemoveLanguages )
            {
            if (  Get-InstalledLanguage -Language $Lang) 
                {
              #  Write-Host "Removing '$Lang' from 'WinUserLanguageList'"
              #  $LanguageList = Get-WinUserLanguageList
              #  $LanguageList.Remove(($LanguageList | Where-Object LanguageTag -like $Lang))
              #  Set-WinUserLanguageList $LanguageList -Force
   
                Write-Host "Un-Installing LanguagePack '$Lang'"
                <#
                    #Requires -RunAsAdministrator
                #>

                Uninstall-Language -Language $Lang -PassThru
                $InstalledLanguages = Get-Language 
                $InstalledLanguages
                }
            }  # ForEach ( $Lang in $RemoveLanguages )
        }
    }
<#
#Requires -RunAsAdministrator
$welcomeScreenKey = "HKEY_USERS\.DEFAULT\Keyboard Layout\Preload"
#Set-ItemProperty $welcomeScreenKey -Name "1" -Value ("0000" + $PreferredKeyBoardLanguageID)
if ( $PreferredKeyBoardLanguageID -ne "0409" )
    { 
    Set-ItemProperty $welcomeScreenKey -Name "2" -Value ("0000" + "0409")    # en-US
    }
#>





# cleanup old /deprecated entries
$LanguageList = Get-WinUserLanguageList
$RemoveResult = $LanguageList.Remove(($LanguageList | Where-Object LanguageTag -like 'en-US'))
$RemoveResult = $LanguageList.Remove(($LanguageList | Where-Object LanguageTag -like 'en-GB'))
ForEach ( $Lang in $RemoveLanguages )
    {
    Write-Host "Removing '$Lang' from 'WinUserLanguageList'"
    $RemoveResult = $LanguageList.Remove(($LanguageList | Where-Object LanguageTag -like $Lang))
    }
Set-WinUserLanguageList $LanguageList -Force





# first element in the list is the DEFAULT keyboard layout
#  -> create a new LanguageList  ( only contzaining PreferredKeyBoardLanguage)
#  -> add (append) all previous entries One-By-One - if not already 'PreferredLanguage'

# [Microsoft.InternationalSettings.Commands.WinUserLanguage]$DefaultEntry = $Null

$CurrentLanguageList = Get-WinUserLanguageList
Write-Host "Create a new Keyboard-LanguageList - first entry '$PreferredKeyBoardLanguage'"
$NewLanguageList     = New-WinUserLanguageList -Language $PreferredKeyBoardLanguage
ForEach ( $CurrentLangListEntry in $CurrentLanguageList )
    {
    If ( $CurrentLangListEntry.LanguageTag -ne $PreferredKeyBoardLanguage)
        {
        Write-Host "Adding existing language '$($CurrentLangListEntry.LanguageTag)' to 'NewLanguageList'"
        $NewLanguageList.Add($CurrentLangListEntry.LanguageTag)             
        }
    Else
        {
        Write-Host "'preferred language' already part of the 'NewLanguageList'"
        }
    }
 $NewLanguageList
 Write-Host "Assigning 'NewLanguageList' to user"
 Set-WinUserLanguageList $NewLanguageList -Force


<#

    # Remove the default US keyboard
    $LanguageList[0].InputMethodTips.Remove('0409:00000409')
    # Add the de-DE keyboard
    $LanguageList[0].InputMethodTips.Add('0407:00000407')
    # And, if you still need the US keyboard as a Taskbar option
    # $LanguageList[0].InputMethodTips.Add('0409:00000409')

    if ( $LanguageList.Count -gt 1 )
        {
        # Remove the default US keyboard
        $LanguageList[1].InputMethodTips.Remove('0409:00000409')
        $LanguageList[1].InputMethodTips.Remove('2000:00000407')
        $LanguageList[1].InputMethodTips.Remove('0407:00000407')
        # Add the de-DE keyboard
        $LanguageList[1].InputMethodTips.Add('0407:00000407')
        $LanguageList[1].InputMethodTips.Add('0409:00000409')
        # And, if you still need the US keyboard as a Taskbar option
        # $LanguageList[1].InputMethodTips.Add('0409:00000409')
        }
#>

Write-Host "Assigning 'TimeZone' to user"
# Get-TimeZone
#                         "W. Europe Standard Time"
Set-TimeZone        -Id "W. Europe Standard Time"


Write-Host "Assigning 'WinSystemLocale' to user"
Set-WinSystemLocale $PreferredKeyBoardLanguage

Write-Host "Assigning 'Culture' to user"
Set-Culture         $PreferredKeyBoardLanguage

# Set-WinUILanguageOverride         -Language fr-BE



$WinDefault = Get-WinDefaultInputMethodOverride -ErrorAction SilentlyContinue
    <#
        InputMethodTip Description              
        -------------- -----------              
        0407:00000407  German (Germany) - German
    
        NOTE:  If you do not get an output, it means "Use language list (recommended)" is currently set as the default input method.

            'Windows Settings' > 'Time & language' > Typing > Advanced keyboard settings

                    Override for default input method
                    If you want to use an input method that's different than the first one in your language list, choose it here

                    German (Germany) - German

    #>
If ( $WinDefault -eq $Null  -or  $WinDefault.InputMethodTip -ne ("0000" + $PreferredKeyBoardLanguageID) )
    {
    Write-Host "Assigning 'WinDefaultInputMethodOverride' "

    Set-WinDefaultInputMethodOverride -InputTip ("0000" + $PreferredKeyBoardLanguageID)
    }

Write-Host "Assigning 'UserInternationalSettingsToSystem' "
Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $True

# REBOOT required

