program DInvader3D;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  GameEngine in 'GameEngine.pas',
  GameObjects in 'GameObjects.pas',
  AudioSystem in 'AudioSystem.pas',
  Renderer3D in 'Renderer3D.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'D-Invader 3D - Space Invaders em Delphi';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.