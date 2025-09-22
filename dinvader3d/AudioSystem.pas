unit AudioSystem;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Winapi.MMSystem;

type
  TAudioSystem = class
  private
    FMasterVolume: Single;
    FMusicVolume: Single;
    FSfxVolume: Single;
    FBackgroundMusicPlaying: Boolean;
    
    procedure PlayBeep(Frequency: Integer; Duration: Integer);
    procedure PlayTone(Frequency: Integer; Duration: Integer; Volume: Single);
  public
    constructor Create;
    destructor Destroy; override;
    
    // Controle de música de fundo
    procedure StartBackgroundMusic;
    procedure StopBackgroundMusic;
    
    // Efeitos sonoros
    procedure PlayPlayerShoot;
    procedure PlayEnemyShoot;
    procedure PlayPlayerHit;
    procedure PlayEnemyHit;
    
    // Controle de volume
    procedure SetMasterVolume(Volume: Single);
    procedure SetMusicVolume(Volume: Single);
    procedure SetSfxVolume(Volume: Single);
    
    // Propriedades
    property MasterVolume: Single read FMasterVolume write SetMasterVolume;
    property MusicVolume: Single read FMusicVolume write SetMusicVolume;
    property SfxVolume: Single read FSfxVolume write SetSfxVolume;
    property BackgroundMusicPlaying: Boolean read FBackgroundMusicPlaying;
  end;

implementation

{ TAudioSystem }

constructor TAudioSystem.Create;
begin
  inherited Create;
  FMasterVolume := 0.3;
  FMusicVolume := 0.1;
  FSfxVolume := 0.4;
  FBackgroundMusicPlaying := False;
end;

destructor TAudioSystem.Destroy;
begin
  StopBackgroundMusic;
  inherited Destroy;
end;

procedure TAudioSystem.PlayBeep(Frequency: Integer; Duration: Integer);
begin
  // Usar Windows Beep API para sons simples
  if (Frequency > 0) and (Duration > 0) then
  begin
    Beep(Frequency, Duration);
  end;
end;

procedure TAudioSystem.PlayTone(Frequency: Integer; Duration: Integer; Volume: Single);
var
  AdjustedFreq: Integer;
begin
  // Ajustar frequência baseado no volume
  AdjustedFreq := Round(Frequency * (Volume * FMasterVolume));
  
  if AdjustedFreq > 37 then // Frequência mínima do Windows Beep
  begin
    // Usar thread para não bloquear a interface
    TThread.CreateAnonymousThread(
      procedure
      begin
        PlayBeep(AdjustedFreq, Duration);
      end
    ).Start;
  end;
end;

procedure TAudioSystem.StartBackgroundMusic;
begin
  if FBackgroundMusicPlaying then Exit;
  
  FBackgroundMusicPlaying := True;
  
  // Criar thread para música de fundo contínua
  TThread.CreateAnonymousThread(
    procedure
    var
      BaseFreq: Integer;
      i: Integer;
    begin
      while FBackgroundMusicPlaying do
      begin
        // Tom ambiente espacial - sequência de tons baixos
        BaseFreq := 80;
        
        for i := 0 to 7 do
        begin
          if not FBackgroundMusicPlaying then Break;
          
          // Variação de frequência para criar ambiente
          PlayBeep(BaseFreq + (i * 5), 500);
          Sleep(600);
          
          if not FBackgroundMusicPlaying then Break;
          PlayBeep(BaseFreq + (8 - i) * 3, 400);
          Sleep(500);
        end;
        
        // Pausa entre ciclos
        Sleep(2000);
      end;
    end
  ).Start;
end;

procedure TAudioSystem.StopBackgroundMusic;
begin
  FBackgroundMusicPlaying := False;
end;

procedure TAudioSystem.PlayPlayerShoot;
begin
  // Som de laser do jogador - frequência alta descendo
  TThread.CreateAnonymousThread(
    procedure
    begin
      PlayTone(800, 100, FSfxVolume);
      Sleep(50);
      PlayTone(600, 80, FSfxVolume);
      Sleep(30);
      PlayTone(400, 60, FSfxVolume);
    end
  ).Start;
end;

procedure TAudioSystem.PlayEnemyShoot;
begin
  // Som de laser inimigo - frequência baixa
  TThread.CreateAnonymousThread(
    procedure
    begin
      PlayTone(200, 150, FSfxVolume);
      Sleep(50);
      PlayTone(150, 100, FSfxVolume);
      Sleep(30);
      PlayTone(100, 80, FSfxVolume);
    end
  ).Start;
end;

procedure TAudioSystem.PlayPlayerHit;
begin
  // Som de alarme quando jogador é atingido
  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
    begin
      for i := 0 to 2 do
      begin
        PlayTone(1000, 100, FSfxVolume);
        Sleep(80);
        PlayTone(800, 100, FSfxVolume);
        Sleep(80);
      end;
    end
  ).Start;
end;

procedure TAudioSystem.PlayEnemyHit;
begin
  // Som de explosão quando inimigo é destruído
  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Freq: Integer;
    begin
      // Sequência de explosão com frequências decrescentes
      for i := 0 to 5 do
      begin
        Freq := 500 - (i * 50);
        if Freq > 37 then
          PlayTone(Freq, 80, FSfxVolume);
        Sleep(40);
      end;
      
      // Som final grave
      PlayTone(100, 200, FSfxVolume);
    end
  ).Start;
end;

procedure TAudioSystem.SetMasterVolume(Volume: Single);
begin
  if Volume < 0 then Volume := 0;
  if Volume > 1 then Volume := 1;
  FMasterVolume := Volume;
end;

procedure TAudioSystem.SetMusicVolume(Volume: Single);
begin
  if Volume < 0 then Volume := 0;
  if Volume > 1 then Volume := 1;
  FMusicVolume := Volume;
end;

procedure TAudioSystem.SetSfxVolume(Volume: Single);
begin
  if Volume < 0 then Volume := 0;
  if Volume > 1 then Volume := 1;
  FSfxVolume := Volume;
end;

end.