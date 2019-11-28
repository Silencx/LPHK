; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define FileHandle
#define FileLine
#define MyAppVersion
#sub ProcessFileLine
  #define FileLine = FileRead(FileHandle)
  #define public MyAppVersion = FileLine
  #pragma message "Version: " + MyAppVersion
#endsub
#for {FileHandle = FileOpen("..\..\VERSION"); \
  FileHandle && !FileEof(FileHandle); ""} \
  ProcessFileLine
#if FileHandle
  #expr FileClose(FileHandle)
#endif

#define MyAppName "LPHK"
#define MyAppPublisher "Ella Jameson (nimaid)"
#define MyAppURL "https://github.com/nimaid/LPHK"
#define MyAppExeName "run.bat"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{A6E030E7-C7D0-4EA7-BBD9-4AD52745451B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=..\__setup__
OutputBaseFilename=LPHK_setup_{#MyAppVersion}
SetupIconFile=..\..\resources\LPHK.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\run.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\*.py"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\VERSION"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\resources\*"; DestDir: "{app}\resources"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\user_layouts\*"; DestDir: "{app}\user_layouts"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\user_scripts\*"; DestDir: "{app}\user_scripts"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\user_sounds\*"; DestDir: "{app}\user_sounds"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\environment.yml"; DestDir: "{tmp}"; Flags: ignoreversion
Source: ".\uninstall_env_windows.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\install_conda_windows.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: ".\install_env_windows.bat"; DestDir: "{tmp}"; Flags: ignoreversion; AfterInstall: MyAfterInstall
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\resources\LPHK.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\resources\LPHK.ico"

[Code]
var CancelWithoutPrompt: boolean;

function InitializeSetup(): Boolean;
begin
  CancelWithoutPrompt := false;
  result := true;
end;

procedure MyAfterInstall();
var ResultCode: integer;
begin
  WizardForm.StatusLabel.Caption := 'Installing Conda...'
  Exec(ExpandConstant('{tmp}\install_conda_windows.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  if ResultCode <> 0 then begin
    MsgBox('Conda could not be installed!',mbError,MB_OK)
    CancelWithoutPrompt := true;
    WizardForm.Close;
  end;

  WizardForm.StatusLabel.Caption := 'Installing LPHK Conda environment...'
  Exec(ExpandConstant('{tmp}\install_env_windows.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  if ResultCode <> 0 then begin
    MsgBox('LPHK Conda environment could not be installed!',mbError,MB_OK)
    CancelWithoutPrompt := true;
    WizardForm.Close;
  end;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if CurPageID=wpInstalling then
    Confirm := not CancelWithoutPrompt;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var ResultCode : Integer;    
begin
  if CurUninstallStep = usUninstall then
  begin
    Exec(ExpandConstant('{app}\uninstall_env_windows.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
    if ResultCode <> 0 then begin
      MsgBox('Could not uninstall Conda environment. You can manually remove it with \"conda env remove -n LPHK\".',mbError,MB_OK)
    end;
  end;
end;

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: shellexec postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
