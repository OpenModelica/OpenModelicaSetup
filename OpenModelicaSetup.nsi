# Adeel Asghar [adeel.asghar@liu.se]
# 2011-jul-29 21:01:29

Unicode true

SetCompressor /FINAL LZMA

!ifndef MSYSRUNTIME
  !error "Argument MSYSRUNTIME is not set. Call with argument /MSYSRUNTIME=mingw|ucrt"
!endif

!ifndef OMVERSION
  !error "Argument OMVERSION is not set. Call with argument /DOMVERSION=OpenModelica version tag"
!endif

!ifndef PRODUCTVERSION
  !error "Argument PRODUCTVERSION is not set. Call with argument /DPRODUCTVERSION=OpenModelica version"
!endif

# Only 64-bit releases are made. The name keeps the 64bit suffix of the earlier releases.
Name OpenModelica${OMVERSION}-64bit

# General Symbol Definitions
!define VERSION ${OMVERSION}-64bit
# Several versions can be installed side by side, so the version is part of the registry keys.
# The key is a sibling of SOFTWARE\OpenModelica and not a subkey of it: the uninstallers of the
# older releases delete the entire SOFTWARE\OpenModelica key.
!define REGKEY "SOFTWARE\OpenModelica ${VERSION}"
# OPENMODELICAHOME_<version> with the version sanitized to letters, digits and underscores,
# e.g. OPENMODELICAHOME_1_27_0, is set for each installation so the clients can find a specific version.
!searchreplace OMVERSION_ENV "${OMVERSION}" "." "_"
!searchreplace OMVERSION_ENV "${OMVERSION_ENV}" "-" "_"
!searchreplace OMVERSION_ENV "${OMVERSION_ENV}" "+" "_"
!searchreplace OMVERSION_ENV "${OMVERSION_ENV}" "~" "_"
!define ENV_OMHOME_VERSION "OPENMODELICAHOME_${OMVERSION_ENV}"
# OMNIGHTLY is defined for the builds that are not made from a release tag.
!ifdef OMNIGHTLY
  !define NIGHTLY 1
!else
  !define NIGHTLY 0
!endif
!define COMPANY "Open Source Modelica Consortium (OSMC) and Linköping University (LiU)."
!define URL "http://www.openmodelica.org/"
BrandingText "Copyright $2 OpenModelica"  ; The $2 variable is filled in the Function .onInit after calling GetLocalTime function.

# MultiUser Symbol Definitions
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_DEFAULT_CURRENTUSER
!define MULTIUSER_INSTALLMODE_COMMANDLINE

# MUI Symbol Definitions
!define MUI_ICON "icons\OpenModelica.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_WELCOMEFINISHPAGE_BITMAP "images\openmodelica.bmp"
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_WELCOMEPAGE_TEXT "The installer will guide you through the steps required to install $(^Name) on your computer.$\r$\n$\r$\n$\r$\nThe package includes OpenModelica, a Modelica modeling, compilation and simulation environment based on free software."
!define MUI_STARTMENUPAGE_REGISTRY_ROOT SHCTX
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${REGKEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "OpenModelica ${OMVERSION}"
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start OpenModelica Connection Editor (OMEdit)"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchOMEdit"
!define MUI_UNICON "icons\OpenModelica.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "images\openmodelica.bmp"

; !defines for use with SHChangeNotify
!ifdef SHCNE_ASSOCCHANGED
!undef SHCNE_ASSOCCHANGED
!endif
!define SHCNE_ASSOCCHANGED 0x08000000
!ifdef SHCNF_FLUSH
!undef SHCNF_FLUSH
!endif
!define SHCNF_FLUSH        0x1000

!macro UPDATEFILEASSOC
; Using the system.dll plugin to call the SHChangeNotify Win32 API function so we
; can update the shell.
  System::Call "shell32::SHChangeNotify(i,i,i,i) (${SHCNE_ASSOCCHANGED}, ${SHCNF_FLUSH}, 0, 0)"
!macroend

# Included files
!include MultiUser.nsh
!include Sections.nsh
!include MUI2.nsh
!include LogicLib.nsh
!include FileFunc.nsh
# Include for some of the windows messages defines
!include "winmessages.nsh"
!include "FileAssociation.nsh"
!include "CustomFunctions.nsh"
!include "UninstallLog.nsh"

; HKLM (all users) vs HKCU (current user) defines
!define ENV_HKLM 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define ENV_HKCU 'HKCU "Environment"'

# Variables
Var StartMenuGroup
Var RemoveNightlies ; 1 if a silent install should remove the other nightly builds
Var un.WasDefault   ; 1 if OPENMODELICAHOME pointed to the installation that is removed
Var un.HadFileAssoc ; 1 if the .mo files were opened by the installation that is removed
Var un.NewDefault   ; the installation that takes over as default, if any

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile "OpenModelica.exe"
CRCCheck on
XPStyle on
ShowInstDetails hide
VIProductVersion ${PRODUCTVERSION}
VIAddVersionKey ProductName "OpenModelica"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
ShowUninstDetails hide

;--------------------------------
; Configure UnInstall log to only remove what is installed
;--------------------------------
;Set the name of the uninstall log
!define UninstLog "uninstall.log"
Var UninstLog

!define UNINSTALL_ROOT "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
; the name of the key used by the releases that could not be installed side by side
!define UNINSTALL_NAME_LEGACY "OpenModelica"
!define UNINSTALL_NAME "OpenModelica ${VERSION}"
!define UNINSTALL_PATH "${UNINSTALL_ROOT}\${UNINSTALL_NAME}"

;Uninstall log file missing.
LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"

;AddItem macro
!define AddItem "!insertmacro AddItem"

;BackupFile macro
!define BackupFile "!insertmacro BackupFile"

;BackupFiles macro
!define BackupFiles "!insertmacro BackupFiles"

;Copy files macro
!define CopyFiles "!insertmacro CopyFiles"

;CreateDirectory macro
!define CreateDirectory "!insertmacro CreateDirectory"

;CreateShortcut macro
!define CreateShortcut "!insertmacro CreateShortcut"

;File macro
!define File "!insertmacro File"

;Rename macro
!define Rename "!insertmacro Rename"

;RestoreFile macro
!define RestoreFile "!insertmacro RestoreFile"

;RestoreFiles macro
!define RestoreFiles "!insertmacro RestoreFiles"

;SetOutPath macro
!define SetOutPath "!insertmacro SetOutPath"

;WriteRegDWORD macro
!define WriteRegDWORD "!insertmacro WriteRegDWORD"

;WriteRegStr macro
!define WriteRegStr "!insertmacro WriteRegStr"

;WriteUninstaller macro
!define WriteUninstaller "!insertmacro WriteUninstaller"

Section -openlogfile
  CreateDirectory "$INSTDIR"
  IfFileExists "$INSTDIR\${UninstLog}" +3
    FileOpen $UninstLog "$INSTDIR\${UninstLog}" w
  Goto +4
    SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
    FileOpen $UninstLog "$INSTDIR\${UninstLog}" a
    FileSeek $UninstLog 0 END
SectionEnd

# Installer sections
Section "OpenModelica Core" Section1
  SectionIn RO
  SetOverwrite on
  ${SetOutPath} "\\?\$INSTDIR\"
  # Create file FilesList.nsh by calling python script GenerateFilesList.py
  !include "FilesList.nsh"
SectionEnd

Section -Main SEC0000
  # create the file with InstallMode
  ${AddItem} "$INSTDIR\InstallMode.txt"
  FileOpen $4 "$INSTDIR\InstallMode.txt" w
  FileWrite $4 $MultiUser.InstallMode
  FileClose $4
  # set the rights for all users
  AccessControl::GrantOnFile "$INSTDIR" "(BU)" "FullAccess"
  # Remove any OPENMODELICALIBRARY environment variable
  DeleteRegValue ${ENV_HKCU} OPENMODELICALIBRARY
  DeleteRegValue ${ENV_HKLM} OPENMODELICALIBRARY
  # create environment variables
  IfSilent KeepOMDEV ; if silent install mode is enabled then skip OMDEV message.
  ReadRegStr $R0 ${ENV_HKLM} OMDEV
  ReadRegStr $R1 ${ENV_HKCU} OMDEV
  ${If} $R0 == ""
  ${AndIf} $R1 == ""
    Goto KeepOMDEV
  ${Else}
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
    "OMDEV environment variable is set.  \
    $\n$\nClick `OK` to remove it. \
    $\nClick `Cancel` to keep it. If you choose to keep it then make sure you update it." \
    IDOK RemoveOMDEV \
    IDCANCEL KeepOMDEV
  ${EndIf}
RemoveOMDEV:
  DeleteRegValue ${ENV_HKLM} OMDEV
  DeleteRegValue ${ENV_HKCU} OMDEV
KeepOMDEV:
  # each installation gets its own OPENMODELICAHOME_<version>, OPENMODELICAHOME is set by the section "Default installation"
  ${If} $MultiUser.InstallMode == "AllUsers"
    WriteRegExpandStr ${ENV_HKLM} "${ENV_OMHOME_VERSION}" "$INSTDIR\"
  ${Else}
    WriteRegExpandStr ${ENV_HKCU} "${ENV_OMHOME_VERSION}" "$INSTDIR\"
  ${EndIf}
SectionEnd

Section -post SEC0001
  # generate group and passwd files for this machine!
  Exec '"$INSTDIR\tools\msys\usr\bin\mkpasswd.exe" -l -c > "$INSTDIR\tools\msys\etc\passwd"'
  Exec '"$INSTDIR\tools\msys\usr\bin\mkgroup.exe" -l -c > "$INSTDIR\tools\msys\etc\group"'
  # Rename libeay32.dll and ssleay32.dll as they seem to have issues on some newer Windows versions
  # https://trac.openmodelica.org/OpenModelica/ticket/5909 https://www.openmodelica.org/forum/default-topic/2944-installation-problems
!if ${MSYSRUNTIME} == "mingw"
  ${Rename} "$INSTDIR\tools\msys\mingw64\bin\libeay32.dll" "$INSTDIR\tools\msys\mingw64\bin\libeay32-O.dll"
  ${Rename} "$INSTDIR\tools\msys\mingw64\bin\ssleay32.dll" "$INSTDIR\tools\msys\mingw64\bin\ssleay32-O.dll"
!endif
  # do post installation actions
  ${WriteRegStr} SHCTX "${REGKEY}" Path $INSTDIR
  ${WriteUninstaller} $INSTDIR\Uninstall.exe
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  # set the output path to temp directory which is used as a start in option for shortcuts.
  SetOutPath "\\?\$TEMP"
  # create shortcuts
  ${CreateDirectory} "$SMPROGRAMS\$StartMenuGroup"
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\OpenModelica Connection Editor.lnk" "$INSTDIR\bin\OMEdit.exe" \
  "" "$INSTDIR\icons\omedit.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\OpenModelica Notebook.lnk" "$INSTDIR\bin\OMNotebook.exe" \
  "" "$INSTDIR\icons\OMNotebook_icon.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\OpenModelica Optimization Editor.lnk" "$INSTDIR\bin\OMOptim.exe" \
  "" "$INSTDIR\icons\omoptim.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\OpenModelica Shell.lnk" "$INSTDIR\bin\OMShell.exe" \
  "" "$INSTDIR\icons\omshell.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\OpenModelica Website.lnk" "$INSTDIR\share\doc\omc\OpenModelica Project Online.url" \
  "" "$INSTDIR\icons\IExplorer.ico" ""
  SetOutPath "\\?\$INSTDIR\"
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\Uninstall OpenModelica.lnk" "$INSTDIR\Uninstall.exe" \
  "" "$INSTDIR\icons\OpenModelica.ico" ""
  ${CreateDirectory} "$SMPROGRAMS\$StartMenuGroup\Documentation"
  SetOutPath ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Users Guide.lnk" "$INSTDIR\share\doc\omc\OpenModelicaUsersGuide.url" \
  "" "$INSTDIR\icons\IExplorer.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Users Guide.pdf.lnk" "$INSTDIR\share\doc\omc\OpenModelicaUsersGuide-latest.pdf" \
  "" "$INSTDIR\icons\PDF.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - MetaProgramming Guide.pdf.lnk" "$INSTDIR\share\doc\omc\SystemDocumentation\OpenModelicaMetaProgramming.pdf" \
  "" "$INSTDIR\icons\PDF.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Modelica Tutorial by Peter Fritzson.pdf.lnk" "$INSTDIR\share\doc\omc\ModelicaTutorialFritzson.pdf" \
  "" "$INSTDIR\icons\PDF.ico" ""
  ${CreateShortcut} "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - System Guide.pdf.lnk" "$INSTDIR\share\doc\omc\SystemDocumentation\OpenModelicaSystem.pdf" \
  "" "$INSTDIR\icons\PDF.ico" ""
  !insertmacro MUI_STARTMENU_WRITE_END
  ${WriteRegStr} SHCTX "${REGKEY}" InstallMode $MultiUser.InstallMode
  ${WriteRegStr} SHCTX "${REGKEY}" Version "${VERSION}"
  ${WriteRegStr} SHCTX "${REGKEY}" Nightly "${NIGHTLY}"
  ${WriteRegStr} SHCTX "${UNINSTALL_PATH}" DisplayName "$(^Name)"
  ${WriteRegStr} SHCTX "${UNINSTALL_PATH}" DisplayVersion "${VERSION}"
  ${WriteRegStr} SHCTX "${UNINSTALL_PATH}" Publisher "${COMPANY}"
  ${WriteRegStr} SHCTX "${UNINSTALL_PATH}" URLInfoAbout "${URL}"
  ${WriteRegStr} SHCTX "${UNINSTALL_PATH}" DisplayIcon $INSTDIR\Uninstall.exe
  ${WriteRegStr} SHCTX "${UNINSTALL_PATH}" UninstallString $INSTDIR\Uninstall.exe
  ${WriteRegDWORD} SHCTX "${UNINSTALL_PATH}" NoModify 1
  ${WriteRegDWORD} SHCTX "${UNINSTALL_PATH}" NoRepair 1
SectionEnd

# The default installation is the one the clients (OMPython, OMJulia, OMMatlab, ...) find via
# OPENMODELICAHOME and the one that opens the .mo and .onb files.
Section "Default installation" SectionDefault
  ${If} $MultiUser.InstallMode == "AllUsers"
    WriteRegExpandStr ${ENV_HKLM} OPENMODELICAHOME "$INSTDIR\"
  ${Else}
    WriteRegExpandStr ${ENV_HKCU} OPENMODELICAHOME "$INSTDIR\"
  ${EndIf}
  ${registerExtension} "$INSTDIR\bin\OMEdit.exe" ".mo" "OpenModelica Connection Editor"
  ${registerExtension} "$INSTDIR\bin\OMNotebook.exe" ".onb" "OpenModelica Notebook"
  # make sure windows knows about the change
  !insertmacro UPDATEFILEASSOC
SectionEnd

Section -environment
  # make sure windows knows about the change i.e we created the environment variables.
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

LangString DESC_Section1 ${LANG_ENGLISH} "OpenModelica ${VERSION}."
LangString DESC_SectionDefault ${LANG_ENGLISH} "Use this version as the default OpenModelica: set the OPENMODELICAHOME environment variable that OMPython, OMJulia, OMMatlab and other clients use to find OpenModelica and open the .mo and .onb files with this version."
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${Section1} $(DESC_Section1)
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionDefault} $(DESC_SectionDefault)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

# Uninstaller sections
Section "Uninstall"
  FileOpen $4 "$INSTDIR\InstallMode.txt" r
  FileSeek $4 0 ; we want to start reading at the 0th byte
  FileRead $4 $1 ; we read until the end of line (including carriage return and new line) and save it to $1
  FileClose $4 ; and close the file
  # Other versions can be installed: OPENMODELICAHOME and the file associations are only touched
  # if they belong to this installation.
  ${If} $1 == "AllUsers"
    SetShellVarContext all
    DeleteRegValue ${ENV_HKLM} "${ENV_OMHOME_VERSION}"
    ReadRegStr $R3 ${ENV_HKLM} OPENMODELICAHOME
  ${Else}
    SetShellVarContext current
    DeleteRegValue ${ENV_HKCU} "${ENV_OMHOME_VERSION}"
    ReadRegStr $R3 ${ENV_HKCU} OPENMODELICAHOME
  ${EndIf}
  StrCpy $un.WasDefault 0
  ${If} $R3 == "$INSTDIR\"
  ${OrIf} $R3 == "$INSTDIR"
    StrCpy $un.WasDefault 1
  ${EndIf}
  StrCpy $un.HadFileAssoc 0
  ReadRegStr $R3 HKCR "OpenModelica Connection Editor\shell\open\command" ""
  ${If} $R3 == '"$INSTDIR\bin\OMEdit.exe" "%1"'
    StrCpy $un.HadFileAssoc 1
  ${EndIf}
  ;Can't uninstall if uninstall log is missing!
  IfFileExists "$INSTDIR\${UninstLog}" +3
    MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
      Abort

  Push $R0
  Push $R1
  Push $R2
  SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" r
  StrCpy $R1 -1

  DetailPrint "Reading $INSTDIR\${UninstLog}"

  GetLineCount:
    ClearErrors
    FileRead $UninstLog $R0
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 -2
    Push $R0
    IfErrors 0 GetLineCount

  Pop $R0

  LoopRead:
    StrCmp $R1 0 LoopDone
    Pop $R0

    IfFileExists "$R0\*.*" 0 +3
      RMDir $R0  #is dir
    Goto +9
    IfFileExists $R0 0 +3
      Delete $R0 #is file
    Goto +6
    StrCmp $R0 "SHCTX ${REGKEY}" 0 +3
      DeleteRegKey SHCTX "${REGKEY}" #is Reg Element
    Goto +3
    StrCmp $R0 "SHCTX ${UNINSTALL_PATH}" 0 +2
      DeleteRegKey SHCTX "${UNINSTALL_PATH}" #is Reg Element

    IntOp $R1 $R1 - 1
    Goto LoopRead
  LoopDone:
  FileClose $UninstLog
  Delete "$INSTDIR\${UninstLog}"
  RMDir "$INSTDIR"
  Pop $R2
  Pop $R1
  Pop $R0

  # Look for another installation to take over as the default one: the keys are enumerated in
  # alphabetical order, so the last one that still has an omc.exe is the highest version string.
  StrCpy $un.NewDefault ""
  StrCpy $R3 0
  ${Do}
    ClearErrors
    EnumRegKey $R4 SHCTX "SOFTWARE" $R3
    ${If} ${Errors}
      ${ExitDo}
    ${EndIf}
    ${If} $R4 == ""
      ${ExitDo}
    ${EndIf}
    IntOp $R3 $R3 + 1
    StrCpy $R5 $R4 13
    ${If} $R5 == "OpenModelica "
      ReadRegStr $R6 SHCTX "SOFTWARE\$R4" "Path"
      ${If} $R6 != ""
      ${AndIf} ${FileExists} "$R6\bin\omc.exe"
        StrCpy $un.NewDefault $R6
      ${EndIf}
    ${EndIf}
  ${Loop}
  ${If} $un.WasDefault == 1
    ${If} $un.NewDefault != ""
      ${If} $1 == "AllUsers"
        WriteRegExpandStr ${ENV_HKLM} OPENMODELICAHOME "$un.NewDefault\"
      ${Else}
        WriteRegExpandStr ${ENV_HKCU} OPENMODELICAHOME "$un.NewDefault\"
      ${EndIf}
    ${ElseIf} $1 == "AllUsers"
      DeleteRegValue ${ENV_HKLM} OPENMODELICAHOME
    ${Else}
      DeleteRegValue ${ENV_HKCU} OPENMODELICAHOME
    ${EndIf}
  ${EndIf}
  ${If} $un.HadFileAssoc == 1
    ${If} $un.NewDefault != ""
      ${un.RegisterExtension} "$un.NewDefault\bin\OMEdit.exe" ".mo" "OpenModelica Connection Editor"
      ${un.RegisterExtension} "$un.NewDefault\bin\OMNotebook.exe" ".onb" "OpenModelica Notebook"
    ${Else}
      ${unregisterExtension} ".mo" "OpenModelica Connection Editor"
      ${unregisterExtension} ".onb" "OpenModelica Notebook"
    ${EndIf}
    # make sure windows knows about the change of file associations
    !insertmacro UPDATEFILEASSOC
  ${EndIf}
  # make sure windows knows about the change i.e we deleted the environment variables.
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

# Installer functions

; Goes through the OpenModelica installations registered in ROOT (HKCU or HKLM).
;  - the same version is removed before it is installed again, the setup quits otherwise
;  - a release from before the side by side installations: offer to remove it
;  - another nightly build, when a nightly build is installed: offer to remove it
;  - any other version is kept
; Uses $R0 and $R2-$R7.
!macro HandleInstalledVersions ROOT
  StrCpy $R3 0
  ${Do}
    ClearErrors
    EnumRegKey $R4 ${ROOT} "${UNINSTALL_ROOT}" $R3
    ${If} ${Errors}
      ${ExitDo}
    ${EndIf}
    ${If} $R4 == ""
      ${ExitDo}
    ${EndIf}
    IntOp $R3 $R3 + 1
    StrCpy $R5 $R4 13
    ${If} $R4 != "${UNINSTALL_NAME_LEGACY}"
    ${AndIf} $R5 != "${UNINSTALL_NAME_LEGACY} "
      ${Continue}
    ${EndIf}
    ReadRegStr $R2 ${ROOT} "${UNINSTALL_ROOT}\$R4" "UninstallString"
    ${IfNot} ${FileExists} "$R2"
      ${Continue}
    ${EndIf}
    ReadRegStr $R7 ${ROOT} "${UNINSTALL_ROOT}\$R4" "DisplayName"
    StrCpy $R6 0 ; 1 = remove it
    ${If} $R4 == "${UNINSTALL_NAME}"
      ${If} ${Silent}
        StrCpy $R6 1
      ${ElseIf} ${Cmd} `MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "$R7 is already installed on your machine.$\n$\nClick 'OK' to uninstall and install again.$\nClick 'Cancel' to quit the setup." IDOK`
        StrCpy $R6 1
      ${Else}
        Quit
      ${EndIf}
    ${ElseIf} $R4 == "${UNINSTALL_NAME_LEGACY}"
      ${If} ${Silent}
        StrCpy $R6 1
      ${ElseIf} ${Cmd} `MessageBox MB_YESNO|MB_ICONQUESTION "$R7 is installed on your machine.$\n$\nBoth versions can be kept, but uninstalling $R7 later on will remove the OPENMODELICAHOME environment variable and the .mo file association of this version.$\n$\nDo you want to uninstall $R7 now?" IDYES`
        StrCpy $R6 1
      ${EndIf}
    ${Else}
!ifdef OMNIGHTLY
      ReadRegStr $R5 ${ROOT} "SOFTWARE\$R4" "Nightly"
      ${If} $R5 == "1"
        ${If} ${Silent}
          StrCpy $R6 $RemoveNightlies
        ${ElseIf} ${Cmd} `MessageBox MB_YESNO|MB_ICONQUESTION "Another OpenModelica nightly build is installed on your machine:$\n$R7$\n$\nDo you want to uninstall it?$\nClick 'No' to keep both." IDYES`
          StrCpy $R6 1
        ${EndIf}
      ${EndIf}
!endif
    ${EndIf}
    ${If} $R6 == 1
      ${GetParent} "$R2" $R0
      ; the _? switch blocks until the uninstall is done, it has to be the last one and unquoted.
      ${If} ${Silent}
        ExecWait '"$R2" /S _?=$R0'
      ${Else}
        ExecWait '"$R2" _?=$R0'
      ${EndIf}
      ClearErrors
      ReadRegStr $R5 ${ROOT} "${UNINSTALL_ROOT}\$R4" "UninstallString"
      ${If} $R5 == ""
        ; with _? the uninstaller cannot delete itself, remove it and the directory if that is all that is left
        Delete "$R2"
        RMDir "$R0"
        ; the key is gone, the next one has moved to its index
        IntOp $R3 $R3 - 1
      ${EndIf}
    ${EndIf}
  ${Loop}
!macroend

Function .onInit
  # Read the current local time of the system and then extract the year from it. This value is then used in Branding Text.
  Call GetLocalTime
  Pop $0  ; Day
  Pop $1  ; Month
  Pop $2  ; Year
  ; disable registry redirection (enable access to 64-bit portion of registry)
  SetRegView 64
  ; command line options, mostly for the silent install:
  ;   /DEFAULT=0        do not make this installation the default one
  ;   /REMOVENIGHTLIES  remove the other nightly builds when a nightly build is installed with /S
  ${GetParameters} $R8
  StrCpy $RemoveNightlies 0
  ClearErrors
  ${GetOptions} $R8 "/REMOVENIGHTLIES" $R9
  ${IfNot} ${Errors}
    StrCpy $RemoveNightlies 1
  ${EndIf}
  ClearErrors
  ${GetOptions} $R8 "/DEFAULT=" $R9
  ${IfNot} ${Errors}
  ${AndIf} $R9 == "0"
    !insertmacro UnselectSection ${SectionDefault}
  ${EndIf}
  ; Check what is already installed, for the current user and for all users
  !insertmacro HandleInstalledVersions HKCU
  !insertmacro HandleInstalledVersions HKLM
  ; the older releases installed with /D registered in the 32-bit portion of the registry
  SetRegView 32
  !insertmacro HandleInstalledVersions HKLM
  SetRegView 64
  InitPluginsDir
  !insertmacro MULTIUSER_INIT
  ; check for /D flag
  ${If} $INSTDIR != ""
    ; /D was used so we don't set the installation path
  ${Else}
    ;set initial value for $INSTDIR
    StrCpy $INSTDIR "$PROGRAMFILES64\$(^Name)"
  ${EndIf}
  ; check for /S flag
  IfSilent +1 +4 ; in silent install mode set multiuser to AllUsers.
    StrCpy $MultiUser.InstallMode "AllUsers"
    SetShellVarContext all
    Goto +3
  StrCpy $MultiUser.InstallMode "CurrentUser"
  SetShellVarContext current
FunctionEnd

Function LaunchOMEdit
  ; Yes we need to set environment variables before starting OMEdit because nsis can't read the new environment variables set by the installer.
  System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("OPENMODELICAHOME", "$INSTDIR\").r0'
  ; Try to unset OPENMODELICALIBRARY environment variable
  System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("OPENMODELICALIBRARY", NULL).r0'
  ; ExecShell passes the elevated UAC of the installer process to OMEdit and as a result drag and drop on OMEdit will not work. Use Exec instead of ExecShell
  ; ExecShell "" "$INSTDIR\bin\OMEdit.exe"
  Exec '"$WINDIR\explorer.exe" "$INSTDIR\bin\OMEdit.exe"'
FunctionEnd

# Uninstaller functions
Function un.onInit
  # Read the current local time of the system and then extract the year from it. This value is then used in Branding Text.
  Call un.GetLocalTime
  Pop $0  ; Day
  Pop $1  ; Month
  Pop $2  ; Year
  ; the installer writes to the 64-bit portion of the registry
  SetRegView 64
  !insertmacro MULTIUSER_UNINIT
FunctionEnd
