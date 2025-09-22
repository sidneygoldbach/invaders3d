unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Menus, System.Types, GameEngine, GameObjects, AudioSystem, Renderer3D;

type
  TfrmMain = class(TForm)
    pbGame: TPaintBox;
    pnlUI: TPanel;
    lblScore: TLabel;
    lblLives: TLabel;
    lblInstructions: TLabel;
    btnStart: TButton;
    btnRestart: TButton;
    tmrGame: TTimer;
    pnlGameOver: TPanel;
    lblGameOver: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnStartClick(Sender: TObject);
    procedure btnRestartClick(Sender: TObject);
    procedure tmrGameTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pbGamePaint(Sender: TObject);
  private
    FGameEngine: TGameEngine;
    FRenderer: TRenderer3D;
    FAudioSystem: TAudioSystem;
    FKeys: TGameKeys;
    procedure InitializeGame;
    procedure UpdateUI;
    procedure ShowGameOver;
    procedure HideGameOver;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Configurar formulário
  Self.Caption := 'D-Invader 3D - Space Invaders em Delphi';
  Self.WindowState := wsMaximized;
  Self.KeyPreview := True;
  Self.DoubleBuffered := True;
  
  // Configurar painel do jogo
  pbGame.Align := alClient;
  pbGame.Color := clBlack;
  pbGame.OnPaint := pbGamePaint;
  
  // Configurar painel da UI
  pnlUI.Align := alTop;
  pnlUI.Height := 60;
  pnlUI.Color := clNavy;
  
  // Configurar labels
  lblScore.Caption := 'Score: 0';
  lblScore.Font.Color := clWhite;
  lblScore.Font.Size := 14;
  lblScore.Font.Style := [fsBold];
  
  lblLives.Caption := 'Lives: 3';
  lblLives.Font.Color := clWhite;
  lblLives.Font.Size := 14;
  lblLives.Font.Style := [fsBold];
  
  lblInstructions.Caption := 'Use A/D para mover, SPACE para atirar, ESC para sair';
  lblInstructions.Font.Color := clYellow;
  lblInstructions.Font.Size := 10;
  
  // Configurar painel de game over
  pnlGameOver.Visible := False;
  pnlGameOver.Color := clMaroon;
  pnlGameOver.Align := alClient;
  lblGameOver.Caption := 'GAME OVER';
  lblGameOver.Font.Color := clWhite;
  lblGameOver.Font.Size := 24;
  lblGameOver.Font.Style := [fsBold];
  
  // Configurar timer
  tmrGame.Interval := 16; // ~60 FPS
  tmrGame.Enabled := False;
  
  // Inicializar sistemas
  InitializeGame;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FGameEngine) then
    FGameEngine.Free;
  if Assigned(FRenderer) then
    FRenderer.Free;
  if Assigned(FAudioSystem) then
    FAudioSystem.Free;
end;

procedure TfrmMain.InitializeGame;
begin
  // Criar sistemas do jogo
  FRenderer := TRenderer3D.Create(pbGame);
  FAudioSystem := TAudioSystem.Create;
  FGameEngine := TGameEngine.Create(FRenderer, FAudioSystem);
  
  // Inicializar controles
  FillChar(FKeys, SizeOf(FKeys), 0);
  
  // Configurar eventos
  FGameEngine.OnScoreChange := UpdateUI;
  FGameEngine.OnLivesChange := UpdateUI;
  FGameEngine.OnGameOver := ShowGameOver;
  
  UpdateUI;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    Ord('A'), VK_LEFT:  FKeys.Left := True;
    Ord('D'), VK_RIGHT: FKeys.Right := True;
    VK_SPACE: FKeys.Space := True;
    VK_ESCAPE: Close;
  end;
  
  if Assigned(FGameEngine) then
    FGameEngine.UpdateKeys(FKeys);
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    Ord('A'), VK_LEFT:  FKeys.Left := False;
    Ord('D'), VK_RIGHT: FKeys.Right := False;
    VK_SPACE: FKeys.Space := False;
  end;
  
  if Assigned(FGameEngine) then
    FGameEngine.UpdateKeys(FKeys);
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  if Assigned(FGameEngine) then
  begin
    FGameEngine.StartGame;
    tmrGame.Enabled := True;
    btnStart.Visible := False;
    HideGameOver;
  end;
end;

procedure TfrmMain.btnRestartClick(Sender: TObject);
begin
  if Assigned(FGameEngine) then
  begin
    FGameEngine.RestartGame;
    tmrGame.Enabled := True;
    HideGameOver;
    UpdateUI;
  end;
end;

procedure TfrmMain.tmrGameTimer(Sender: TObject);
begin
  if Assigned(FGameEngine) then
  begin
    FGameEngine.Update;
    pbGame.Invalidate; // Força repaint
  end;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  if Assigned(FRenderer) then
    FRenderer.Resize(pbGame.Width, pbGame.Height);
end;

procedure TfrmMain.pbGamePaint(Sender: TObject);
begin
  if Assigned(FRenderer) and Assigned(FGameEngine) then
  begin
    FRenderer.BeginRender;
    FGameEngine.Render;
    FRenderer.EndRender;
  end;
end;

procedure TfrmMain.UpdateUI;
begin
  if Assigned(FGameEngine) then
  begin
    lblScore.Caption := 'Score: ' + IntToStr(FGameEngine.Score);
    lblLives.Caption := 'Lives: ' + IntToStr(FGameEngine.Lives);
  end;
end;

procedure TfrmMain.ShowGameOver;
begin
  tmrGame.Enabled := False;
  pnlGameOver.Visible := True;
  pnlGameOver.BringToFront;
  btnRestart.Visible := True;
end;

procedure TfrmMain.HideGameOver;
begin
  pnlGameOver.Visible := False;
  btnRestart.Visible := False;
end;

end.