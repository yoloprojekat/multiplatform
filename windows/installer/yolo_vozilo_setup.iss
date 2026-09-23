; =====================================================================
; YOLO VOZILO COCKPIT - Inno Setup Script
; High-performance Windows Desktop Installer
; =====================================================================

#define MyAppName "YOLO Vozilo Cockpit"
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#define MyAppPublisher "Danilo Stoletović"
#define MyAppURL "https://github.com/danilo-stoletovic/multiplatform"
#define MyAppExeName "multiplatform.exe"

#ifndef BuildDir
  #define BuildDir "..\..\build\windows\x64\runner\Release"
#endif

[Setup]
; Unique AppId identifier for update/uninstall integrity
AppId={{5E41A2D6-8F12-4299-90C7-B2A65F096E82}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; Installation target directory ({autopf} expands to Program Files or Local AppData)
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\..\LICENSE

; Installer binary properties
OutputDir=..\..\build\windows\installer
OutputBaseFilename=yolo-vozilo-windows-installer
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

; High-ratio solid compression
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

; 64-bit architecture enforcement
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible

; Allow user to choose install scope (All Users vs Current User)
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; Visual style
DisableProgramGroupPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main executable
Source: "{#BuildDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; All dependent DLLs, Flutter engine, data folder, and assets
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Start Menu shortcut
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
; Desktop shortcut (optional task)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Launch application option upon setup completion
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
