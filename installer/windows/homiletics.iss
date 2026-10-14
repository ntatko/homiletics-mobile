; Inno Setup script for the Homiletics Windows installer.
;
; Built by .github/workflows/windows-release.yml after
; `flutter build windows --release`:
;
;   iscc /DAppVersion=3.0.0 /DSourceDir=<repo>\build\windows\x64\runner\Release ^
;        /DOutputDir=<repo>\dist installer\windows\homiletics.iss
;
; Installs per user (no admin prompt) by default; the user can choose an
; all-users install from the dialog, which then asks for admin rights.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\dist"
#endif

#define AppName "Homiletics"
#define AppPublisher "13one"
#define AppExeName "Homiletics.exe"
#define AppURL "https://github.com/ntatko/homiletics-mobile"

[Setup]
; Never change AppId: it is how upgrades find the existing installation.
AppId={{DACD937B-A7A5-4896-8786-F2817A069C86}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}/issues
AppUpdatesURL={#AppURL}/releases
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoProductName={#AppName}
; {autopf} is %LOCALAPPDATA%\Programs for a per-user install and
; Program Files for an all-users one.
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDir}
OutputBaseFilename=Homiletics-Setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}
LicenseFile=..\..\LICENSE
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
; The app quits itself before an in-app update runs this installer, and
; the [Run] entry below reopens it; Restart Manager restarting it too
; would open it twice.
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[INI]
; Marks an installed (not portable zip) copy, so the app knows it can
; update itself by running a newer Homiletics-Setup.exe (see
; lib/services/update_service.dart).
Filename: "{app}\install.ini"; Section: "Install"; Key: "Source"; String: "setup"
Filename: "{app}\install.ini"; Section: "Install"; Key: "Version"; String: "{#AppVersion}"

[UninstallDelete]
Type: files; Name: "{app}\install.ini"

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
; An in-app update runs this installer with /SILENT /RELAUNCH=1: reopen
; the app when it's done, as the signed-in user rather than elevated.
Filename: "{app}\{#AppExeName}"; Flags: nowait runasoriginaluser; Check: ShouldRelaunch

[Code]
function ShouldRelaunch: Boolean;
begin
  Result := WizardSilent and (ExpandConstant('{param:RELAUNCH|0}') = '1');
end;
