program DInvader3D;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  GameEngine in 'GameEngine.pas',
  GameObjects in 'GameObjects.pas',
  AudioSystem in 'AudioSystem.pas',
  Renderer3D in 'Renderer3D.pas',
  SpriteManager in 'SpriteManager.pas',
  EffectsManager in 'EffectsManager.pas';

{$R *.res}
// {$R sprites.res}  // Comentado temporariamente até compilar o arquivo de recursos

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'D-Invader 3D - Space Invaders em Delphi';
  // Corrigido: TfrmMain e frmMain (não TForm1 e Form1)
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.