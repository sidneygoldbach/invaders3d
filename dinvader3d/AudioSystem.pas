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
  // Som de laser do jogador - tom único mais suave
  TThread.CreateAnonymousThread(
    procedure
    begin
      PlayTone(600, 200, FSfxVolume * 0.7); // Tom mais baixo e mais longo
    end
  ).Start;
end;

procedure TAudioSystem.PlayEnemyShoot;
begin
  // Som de laser inimigo - tom grave único
  TThread.CreateAnonymousThread(
    procedure
    begin
      PlayTone(300, 250, FSfxVolume * 0.6); // Tom grave mais longo
    end
  ).Start;
end;

procedure TAudioSystem.PlayPlayerHit;
begin
  // Som de alarme quando jogador é atingido - mais suave
  TThread.CreateAnonymousThread(
    procedure
    begin
      PlayTone(800, 300, FSfxVolume * 0.8); // Tom único mais longo
      Sleep(100);
      PlayTone(600, 200, FSfxVolume * 0.6); // Tom de follow-up
    end
  ).Start;
end;

procedure TAudioSystem.PlayEnemyHit;
begin
  // Som de explosão quando inimigo é destruído - mais suave
  TThread.CreateAnonymousThread(
    procedure
    begin
      PlayTone(400, 300, FSfxVolume * 0.8); // Tom médio
      Sleep(100);
      PlayTone(200, 400, FSfxVolume * 0.6); // Tom grave final
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