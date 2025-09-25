program DInvader3D;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  GameEngine in 'GameEngine.pas',
  GameObjects in 'GameObjects.pas',
  AudioSystem in 'AudioSystem.pas',
  Renderer3D in 'Renderer3D.pas',
  SpriteManager in 'SpriteManager.pas',
  EffectsManager in 'EffectsManager.pas';

{$R *.res}
{$R sprites.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'D-Invader 3D - Space Invaders em Delphi';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.