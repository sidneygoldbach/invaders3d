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
  AdjustedDuration: Integer;
  FinalVolume: Single;
begin
  // Calcular volume final sem distorção
  FinalVolume := Volume * FMasterVolume;
  if FinalVolume > 1.0 then FinalVolume := 1.0;
  
  // Ajustar frequência de forma mais suave
  AdjustedFreq := Round(Frequency);
  
  // Limitar duração para evitar sobreposição
  AdjustedDuration := Min(Duration, 500);
  
  if (AdjustedFreq >= 37) and (AdjustedFreq <= 32767) then // Limites do Windows Beep
  begin
    // Usar thread para não bloquear a interface
    TThread.CreateAnonymousThread(
      procedure
      begin
        try
          // Pequena pausa antes do som para evitar estalos
          Sleep(10);
          PlayBeep(AdjustedFreq, AdjustedDuration);
        except
          // Ignorar erros de áudio silenciosamente
        end;
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
        try
          // Tom ambiente espacial - sequência de tons baixos mais suaves
          BaseFreq := 60; // Frequência mais baixa para ambiente
          
          for i := 0 to 5 do // Menos repetições
          begin
            if not FBackgroundMusicPlaying then Break;
            
            // Variação de frequência mais suave
            PlayBeep(BaseFreq + (i * 3), 400); // Duração menor
            Sleep(800); // Pausa maior entre tons
            
            if not FBackgroundMusicPlaying then Break;
            Sleep(600);
          end;
          
          // Pausa maior entre ciclos
          Sleep(4000);
        except
          // Continuar mesmo com erros
        end;
      end;
    end
  ).Start;
end;

procedure TAudioSystem.PlayPlayerShoot;
begin
  // Som de laser do jogador - mais suave e curto
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        PlayTone(500, 150, FSfxVolume * 0.5); // Frequência e volume menores
      except
        // Ignorar erros
      end;
    end
  ).Start;
end;

procedure TAudioSystem.PlayEnemyShoot;
begin
  // Som de laser inimigo - tom grave mais suave
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        PlayTone(250, 180, FSfxVolume * 0.4); // Mais suave
      except
        // Ignorar erros
      end;
    end
  ).Start;
end;

procedure TAudioSystem.PlayPlayerHit;
begin
  // Som de alarme quando jogador é atingido - simplificado
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        PlayTone(600, 200, FSfxVolume * 0.6); // Som único mais suave
        Sleep(150);
        PlayTone(400, 150, FSfxVolume * 0.4); // Tom de follow-up mais baixo
      except
        // Ignorar erros
      end;
    end
  ).Start;
end;

procedure TAudioSystem.PlayEnemyHit;
begin
  // Som de explosão quando inimigo é destruído - simplificado
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        PlayTone(300, 200, FSfxVolume * 0.6); // Tom médio mais suave
        Sleep(120);
        PlayTone(150, 250, FSfxVolume * 0.4); // Tom grave final mais baixo
      except
        // Ignorar erros
      end;
    end
  ).Start;
end;

procedure TAudioSystem.StopBackgroundMusic;
begin
  FBackgroundMusicPlaying := False;
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