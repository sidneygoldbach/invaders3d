unit SpriteManager;

interface

uses
  Winapi.Windows, System.Classes, System.UITypes, Vcl.Graphics, System.SysUtils, System.Math;

type
  // Tipos de sprites disponíveis
  TSpriteType = (
    stPlayerRobot,
    stUfoClassic,
    stFighterJet,
    stParatrooper,
    stLaserBeam,
    stExplosionParticle,
    stStarfieldBg
  );

  // Classe para gerenciar sprites 3D
  TSpriteManager = class
  private
    FCanvas: TCanvas;
    FSprites: array[TSpriteType] of TBitmap;
    FLoaded: Boolean;
    
    function LoadSpriteFromResource(const ResourceName: string): TBitmap;
    function SVGToBitmap(const SVGData: string; Width, Height: Integer; const ResourceName: string): TBitmap;
    procedure CreateGradientBitmap(Bitmap: TBitmap; const Colors: array of TColor; 
      CenterX, CenterY, Radius: Integer);
    procedure Draw3DSphere(Bitmap: TBitmap; X, Y, Radius: Integer; 
      const Colors: array of TColor);
    procedure DrawGlowEffect(Bitmap: TBitmap; X, Y, Radius: Integer; 
      Color: TColor; Intensity: Single);
    
    // Métodos para criar sprites 3D específicos
    procedure CreateRobot3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
    procedure CreateUFO3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
    procedure CreateFighterJet3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
    procedure CreateParatrooper3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
    procedure CreateLaserBeam3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
    procedure CreateExplosion3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
    procedure CreateStarfield3D(Bitmap: TBitmap);
      
  public
    constructor Create(Canvas: TCanvas);
    destructor Destroy; override;
    
    procedure LoadSprites;
    procedure DrawSprite(SpriteType: TSpriteType; X, Y: Integer; 
      Scale: Single = 1.0; Rotation: Single = 0.0; Alpha: Byte = 255);
    procedure DrawAnimatedSprite(SpriteType: TSpriteType; X, Y: Integer; 
      Frame: Integer; Scale: Single = 1.0; Rotation: Single = 0.0; Alpha: Byte = 255);
    
    property Canvas: TCanvas read FCanvas write FCanvas;
    property Loaded: Boolean read FLoaded;
  end;

implementation

{ TSpriteManager }

constructor TSpriteManager.Create(Canvas: TCanvas);
var
  SpriteType: TSpriteType;
begin
  inherited Create;
  FCanvas := Canvas;
  FLoaded := False;
  
  // Inicializar bitmaps
  for SpriteType := Low(TSpriteType) to High(TSpriteType) do
    FSprites[SpriteType] := TBitmap.Create;
end;

destructor TSpriteManager.Destroy;
var
  SpriteType: TSpriteType;
begin
  for SpriteType := Low(TSpriteType) to High(TSpriteType) do
    FSprites[SpriteType].Free;
    
  inherited Destroy;
end;

function TSpriteManager.LoadSpriteFromResource(const ResourceName: string): TBitmap;
var
  ResourceStream: TResourceStream;
  SVGData: string;
  StringList: TStringList;
  SVGFileName: string;
begin
  Result := TBitmap.Create;
  
  try
    // Primeiro, tentar carregar SVG do recurso
    ResourceStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
    try
      StringList := TStringList.Create;
      try
        StringList.LoadFromStream(ResourceStream);
        SVGData := StringList.Text;
        
        // Converter SVG para bitmap (implementação simplificada)
        Result := SVGToBitmap(SVGData, 128, 128, ResourceName);
        
      finally
        StringList.Free;
      end;
    finally
      ResourceStream.Free;
    end;
    
  except
    on E: Exception do
    begin
      // Se falhar ao carregar do recurso, tentar carregar arquivo SVG diretamente
      SVGFileName := '';
      
      if ResourceName = 'PLAYER_ROBOT' then
        SVGFileName := 'player_robot.svg'
      else if ResourceName = 'UFO_CLASSIC' then
        SVGFileName := 'ufo_classic.svg'
      else if ResourceName = 'FIGHTER_JET' then
        SVGFileName := 'fighter_jet.svg'
      else if ResourceName = 'PARATROOPER' then
        SVGFileName := 'paratrooper.svg'
      else if ResourceName = 'LASER_BEAM' then
        SVGFileName := 'laser_beam.svg'
      else if ResourceName = 'EXPLOSION_PARTICLE' then
        SVGFileName := 'explosion_particle.svg'
      else if ResourceName = 'STARFIELD_BG' then
        SVGFileName := 'starfield_bg.svg';
      
      // Tentar carregar arquivo SVG do disco
      if (SVGFileName <> '') and FileExists(SVGFileName) then
      begin
        try
          StringList := TStringList.Create;
          try
            StringList.LoadFromFile(SVGFileName);
            SVGData := StringList.Text;
            Result := SVGToBitmap(SVGData, 128, 128, ResourceName);
          finally
            StringList.Free;
          end;
        except
          // Se falhar ao carregar SVG do disco, usar sprite 3D procedural como último recurso
          Result.Width := 128;
          Result.Height := 128;
          Result.PixelFormat := pf32bit;
          
          if ResourceName = 'PLAYER_ROBOT' then
            Draw3DSphere(Result, 64, 64, 30, [$00FFFFFF, $00AAAAFF, $004488CC, $00224466])
          else if ResourceName = 'UFO_CLASSIC' then
            Draw3DSphere(Result, 64, 64, 35, [$00CCCCCC, $00888888, $00444444, $00222222])
          else if ResourceName = 'FIGHTER_JET' then
            Draw3DSphere(Result, 64, 64, 25, [$00DDDDDD, $00999999, $00555555, $00333333])
          else if ResourceName = 'PARATROOPER' then
            Draw3DSphere(Result, 64, 64, 20, [$0088AA88, $00556655, $00334433, $00223322])
          else if ResourceName = 'LASER_BEAM' then
            Draw3DSphere(Result, 64, 64, 15, [$00FFFFFF, $00AAFFFF, $0000FFFF, $000088FF])
          else if ResourceName = 'EXPLOSION_PARTICLE' then
            Draw3DSphere(Result, 64, 64, 40, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400])
          else
            Draw3DSphere(Result, 64, 64, 32, [$00FFFFFF, $00CCCCCC, $00888888, $00444444]);
        end;
      end
      else
      begin
        // Se não encontrar arquivo SVG, usar sprite 3D procedural
        Result.Width := 128;
        Result.Height := 128;
        Result.PixelFormat := pf32bit;
        
        if ResourceName = 'PLAYER_ROBOT' then
          Draw3DSphere(Result, 64, 64, 30, [$00FFFFFF, $00AAAAFF, $004488CC, $00224466])
        else if ResourceName = 'UFO_CLASSIC' then
          Draw3DSphere(Result, 64, 64, 35, [$00CCCCCC, $00888888, $00444444, $00222222])
        else if ResourceName = 'FIGHTER_JET' then
          Draw3DSphere(Result, 64, 64, 25, [$00DDDDDD, $00999999, $00555555, $00333333])
        else if ResourceName = 'PARATROOPER' then
          Draw3DSphere(Result, 64, 64, 20, [$0088AA88, $00556655, $00334433, $00223322])
        else if ResourceName = 'LASER_BEAM' then
          Draw3DSphere(Result, 64, 64, 15, [$00FFFFFF, $00AAFFFF, $0000FFFF, $000088FF])
        else if ResourceName = 'EXPLOSION_PARTICLE' then
          Draw3DSphere(Result, 64, 64, 40, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400])
        else
          Draw3DSphere(Result, 64, 64, 32, [$00FFFFFF, $00CCCCCC, $00888888, $00444444]);
      end;
    end;
  end;
end;

function TSpriteManager.SVGToBitmap(const SVGData: string; Width, Height: Integer; const ResourceName: string): TBitmap;
var
  i, j: Integer;
  centerX, centerY: Integer;
  distance: Single;
  pixelColor: TColor;
  scanLine: PByteArray;
  normalizedDist: Single;
  r, g, b: Byte;
  alpha: Byte;
begin
  Result := TBitmap.Create;
  Result.Width := Width;
  Result.Height := Height;
  Result.PixelFormat := pf32bit;
  
  centerX := Width div 2;
  centerY := Height div 2;
  
  // Analisar o ResourceName e criar sprite 3D correspondente
  if ResourceName = 'PLAYER_ROBOT' then
  begin
    // Criar robô 3D detalhado
    CreateRobot3D(Result, centerX, centerY);
  end
  else if ResourceName = 'UFO_CLASSIC' then
  begin
    // Criar UFO 3D detalhado
    CreateUFO3D(Result, centerX, centerY);
  end
  else if ResourceName = 'FIGHTER_JET' then
  begin
    // Criar jato 3D detalhado
    CreateFighterJet3D(Result, centerX, centerY);
  end
  else if ResourceName = 'PARATROOPER' then
  begin
    // Criar paraquedista 3D detalhado
    CreateParatrooper3D(Result, centerX, centerY);
  end
  else if ResourceName = 'LASER_BEAM' then
  begin
    // Criar laser 3D detalhado
    CreateLaserBeam3D(Result, centerX, centerY);
  end
  else if ResourceName = 'EXPLOSION_PARTICLE' then
  begin
    // Criar explosão 3D detalhada
    CreateExplosion3D(Result, centerX, centerY);
  end
  else if ResourceName = 'STARFIELD_BG' then
  begin
    // Criar campo de estrelas 3D
    CreateStarfield3D(Result);
  end
  else
  begin
    // Fallback para esfera genérica
    Draw3DSphere(Result, centerX, centerY, 32, [$00FFFFFF, $00CCCCCC, $00888888, $00444444]);
  end;
end;

procedure TSpriteManager.Draw3DSphere(Bitmap: TBitmap; X, Y, Radius: Integer; 
  const Colors: array of TColor);
var
  i, j: Integer;
  dx, dy, distance: Single;
  normalizedDist: Single;
  colorIndex: Integer;
  r1, g1, b1, r2, g2, b2: Byte;
  finalR, finalG, finalB: Byte;
  blend: Single;
  pixelColor: TColor;
  scanLine: PByteArray;
begin
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  for j := 0 to Bitmap.Height - 1 do
  begin
    scanLine := Bitmap.ScanLine[j];
    for i := 0 to Bitmap.Width - 1 do
    begin
      dx := i - X;
      dy := j - Y;
      distance := Sqrt(dx * dx + dy * dy);
      
      if distance <= Radius then
      begin
        // Calcular iluminação 3D
        normalizedDist := distance / Radius;
        
        // Determinar cor baseada na distância do centro
        if normalizedDist < 0.25 then
        begin
          colorIndex := 0;
          blend := normalizedDist * 4;
        end
        else if normalizedDist < 0.5 then
        begin
          colorIndex := 1;
          blend := (normalizedDist - 0.25) * 4;
        end
        else if normalizedDist < 0.75 then
        begin
          colorIndex := 2;
          blend := (normalizedDist - 0.5) * 4;
        end
        else
        begin
          colorIndex := 3;
          blend := (normalizedDist - 0.75) * 4;
        end;
        
        // Interpolar entre cores
        if colorIndex < High(Colors) then
        begin
          r1 := GetRValue(Colors[colorIndex]);
          g1 := GetGValue(Colors[colorIndex]);
          b1 := GetBValue(Colors[colorIndex]);
          
          r2 := GetRValue(Colors[colorIndex + 1]);
          g2 := GetGValue(Colors[colorIndex + 1]);
          b2 := GetBValue(Colors[colorIndex + 1]);
          
          finalR := Round(r1 + (r2 - r1) * blend);
          finalG := Round(g1 + (g2 - g1) * blend);
          finalB := Round(b1 + (b2 - b1) * blend);
        end
        else
        begin
          finalR := GetRValue(Colors[High(Colors)]);
          finalG := GetGValue(Colors[High(Colors)]);
          finalB := GetBValue(Colors[High(Colors)]);
        end;
        
        // Aplicar efeito de iluminação 3D
        if normalizedDist < 0.3 then
        begin
          // Brilho especular
          finalR := Min(255, Round(finalR * 1.5));
          finalG := Min(255, Round(finalG * 1.5));
          finalB := Min(255, Round(finalB * 1.5));
        end;
        
        pixelColor := RGB(finalR, finalG, finalB);
        
        // Definir pixel (formato BGRA)
        scanLine[i * 4] := GetBValue(pixelColor);     // B
        scanLine[i * 4 + 1] := GetGValue(pixelColor); // G
        scanLine[i * 4 + 2] := GetRValue(pixelColor); // R
        scanLine[i * 4 + 3] := 255;                   // A
      end;
    end;
  end;
end;

procedure TSpriteManager.CreateGradientBitmap(Bitmap: TBitmap; const Colors: array of TColor; 
  CenterX, CenterY, Radius: Integer);
var
  i, j: Integer;
  distance: Single;
  colorIndex: Integer;
  blend: Single;
begin
  for j := 0 to Bitmap.Height - 1 do
  begin
    for i := 0 to Bitmap.Width - 1 do
    begin
      distance := Sqrt(Sqr(i - CenterX) + Sqr(j - CenterY));
      
      if distance <= Radius then
      begin
        colorIndex := Trunc((distance / Radius) * (Length(Colors) - 1));
        blend := Frac((distance / Radius) * (Length(Colors) - 1));
        
        // Interpolar cores e desenhar pixel
        // Implementação simplificada
        Bitmap.Canvas.Pixels[i, j] := Colors[Min(colorIndex, High(Colors))];
      end;
    end;
  end;
end;

procedure TSpriteManager.DrawGlowEffect(Bitmap: TBitmap; X, Y, Radius: Integer; 
  Color: TColor; Intensity: Single);
var
  i, j: Integer;
  distance: Single;
  alpha: Byte;
begin
  for j := Y - Radius to Y + Radius do
  begin
    for i := X - Radius to X + Radius do
    begin
      if (i >= 0) and (i < Bitmap.Width) and (j >= 0) and (j < Bitmap.Height) then
      begin
        distance := Sqrt(Sqr(i - X) + Sqr(j - Y));
        
        if distance <= Radius then
        begin
          alpha := Round(255 * Intensity * (1 - distance / Radius));
          // Aplicar efeito de brilho (implementação simplificada)
          Bitmap.Canvas.Pixels[i, j] := Color;
        end;
      end;
    end;
  end;
end;

procedure TSpriteManager.LoadSprites;
begin
  try
    FSprites[stPlayerRobot] := LoadSpriteFromResource('PLAYER_ROBOT');
    FSprites[stUfoClassic] := LoadSpriteFromResource('UFO_CLASSIC');
    FSprites[stFighterJet] := LoadSpriteFromResource('FIGHTER_JET');
    FSprites[stParatrooper] := LoadSpriteFromResource('PARATROOPER');
    FSprites[stLaserBeam] := LoadSpriteFromResource('LASER_BEAM');
    FSprites[stExplosionParticle] := LoadSpriteFromResource('EXPLOSION_PARTICLE');
    FSprites[stStarfieldBg] := LoadSpriteFromResource('STARFIELD_BG');
    
    FLoaded := True;
  except
    on E: Exception do
    begin
      // Log do erro (implementar conforme necessário)
      FLoaded := False;
    end;
  end;
end;

procedure TSpriteManager.DrawSprite(SpriteType: TSpriteType; X, Y: Integer; 
  Scale: Single; Rotation: Single; Alpha: Byte);
var
  Bitmap: TBitmap;
  DestRect, SrcRect: TRect;
  ScaledWidth, ScaledHeight: Integer;
begin
  if not FLoaded or not Assigned(FCanvas) then
    Exit;
    
  Bitmap := FSprites[SpriteType];
  if not Assigned(Bitmap) then
    Exit;
    
  ScaledWidth := Round(Bitmap.Width * Scale);
  ScaledHeight := Round(Bitmap.Height * Scale);
  
  DestRect := Rect(X - ScaledWidth div 2, Y - ScaledHeight div 2, 
                   X + ScaledWidth div 2, Y + ScaledHeight div 2);
  SrcRect := Rect(0, 0, Bitmap.Width, Bitmap.Height);
  
  // Aplicar transparência se necessário
  if Alpha < 255 then
  begin
    // Implementar blend de alpha (simplificado)
    FCanvas.CopyMode := cmSrcCopy;
  end;
  
  // Desenhar sprite (rotação seria implementada com transformações mais complexas)
  FCanvas.CopyRect(DestRect, Bitmap.Canvas, SrcRect);
end;

procedure TSpriteManager.DrawAnimatedSprite(SpriteType: TSpriteType; X, Y: Integer; 
  Frame: Integer; Scale: Single; Rotation: Single; Alpha: Byte);
var
  AnimRotation: Single;
  AnimScale: Single;
begin
  // Adicionar efeitos de animação baseados no frame
  AnimRotation := Rotation + (Frame * 5); // Rotação animada
  AnimScale := Scale + Sin(Frame * 0.1) * 0.1; // Pulsação
  
  DrawSprite(SpriteType, X, Y, AnimScale, AnimRotation, Alpha);
end;

// Implementações dos métodos para criar sprites 3D específicos

procedure TSpriteManager.CreateRobot3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Limpar bitmap
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  // Corpo principal do robô (esfera azul metálica)
  Draw3DSphere(Bitmap, CenterX, CenterY + 10, 35, [$00FFFFFF, $00AAAAFF, $004488CC, $00224466]);
  
  // Cabeça do robô (esfera menor)
  Draw3DSphere(Bitmap, CenterX, CenterY - 25, 20, [$00FFFFFF, $00CCCCFF, $006699DD, $00334477]);
  
  // Olhos vermelhos brilhantes
  Draw3DSphere(Bitmap, CenterX - 8, CenterY - 28, 4, [$00FFFFFF, $00FFAAAA, $00FF4444, $00AA0000]);
  Draw3DSphere(Bitmap, CenterX + 8, CenterY - 28, 4, [$00FFFFFF, $00FFAAAA, $00FF4444, $00AA0000]);
  
  // Braços robóticos
  Draw3DSphere(Bitmap, CenterX - 40, CenterY, 15, [$00DDDDDD, $00AAAAAA, $00777777, $00444444]);
  Draw3DSphere(Bitmap, CenterX + 40, CenterY, 15, [$00DDDDDD, $00AAAAAA, $00777777, $00444444]);
  
  // Jatos propulsores (efeito de fogo)
  Draw3DSphere(Bitmap, CenterX - 15, CenterY + 45, 8, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400]);
  Draw3DSphere(Bitmap, CenterX + 15, CenterY + 45, 8, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400]);
end;

procedure TSpriteManager.CreateUFO3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Limpar bitmap
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  // Corpo principal do UFO (disco achatado)
  Draw3DSphere(Bitmap, CenterX, CenterY + 5, 45, [$00CCCCCC, $00888888, $00444444, $00222222]);
  
  // Cúpula superior transparente
  Draw3DSphere(Bitmap, CenterX, CenterY - 10, 25, [$00FFFFFF, $00AAFFFF, $004488CC, $00224466]);
  
  // Luzes coloridas ao redor do disco
  Draw3DSphere(Bitmap, CenterX - 35, CenterY + 5, 6, [$00FFFFFF, $00FF4444, $00AA0000, $00550000]);
  Draw3DSphere(Bitmap, CenterX - 12, CenterY + 15, 6, [$00FFFFFF, $0044FF44, $0000AA00, $00005500]);
  Draw3DSphere(Bitmap, CenterX + 12, CenterY + 15, 6, [$00FFFFFF, $004444FF, $000000AA, $00000055]);
  Draw3DSphere(Bitmap, CenterX + 35, CenterY + 5, 6, [$00FFFFFF, $00FFFF44, $00AAAA00, $00555500]);
  
  // Raio trator (opcional)
  Draw3DSphere(Bitmap, CenterX, CenterY + 35, 12, [$00FFFFFF, $00AAFFFF, $0044AAFF, $00226688]);
end;

procedure TSpriteManager.CreateFighterJet3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Limpar bitmap
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  // Fuselagem principal
  Draw3DSphere(Bitmap, CenterX, CenterY, 30, [$00DDDDDD, $00999999, $00555555, $00333333]);
  
  // Cockpit
  Draw3DSphere(Bitmap, CenterX, CenterY - 15, 18, [$00FFFFFF, $00AAFFFF, $0066AADD, $00335577]);
  
  // Asas
  Draw3DSphere(Bitmap, CenterX - 35, CenterY + 10, 20, [$00BBBBBB, $00888888, $00444444, $00222222]);
  Draw3DSphere(Bitmap, CenterX + 35, CenterY + 10, 20, [$00BBBBBB, $00888888, $00444444, $00222222]);
  
  // Motores/Jatos
  Draw3DSphere(Bitmap, CenterX - 20, CenterY + 35, 10, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400]);
  Draw3DSphere(Bitmap, CenterX + 20, CenterY + 35, 10, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400]);
end;

procedure TSpriteManager.CreateParatrooper3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Limpar bitmap
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  // Paraquedas
  Draw3DSphere(Bitmap, CenterX, CenterY - 20, 40, [$00FFFFFF, $0088AA88, $00556655, $00334433]);
  
  // Corpo do paraquedista
  Draw3DSphere(Bitmap, CenterX, CenterY + 15, 12, [$00DDDDDD, $00999999, $00666666, $00333333]);
  
  // Cabeça
  Draw3DSphere(Bitmap, CenterX, CenterY + 5, 8, [$00FFDDAA, $00DDAA88, $00AA7755, $00774433]);
  
  // Equipamentos
  Draw3DSphere(Bitmap, CenterX - 8, CenterY + 18, 5, [$00AAAAAA, $00777777, $00444444, $00222222]);
  Draw3DSphere(Bitmap, CenterX + 8, CenterY + 18, 5, [$00AAAAAA, $00777777, $00444444, $00222222]);
end;

procedure TSpriteManager.CreateLaserBeam3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Limpar bitmap
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  // Núcleo do laser (muito brilhante)
  Draw3DSphere(Bitmap, CenterX, CenterY, 8, [$00FFFFFF, $00FFFFFF, $00AAFFFF, $0066AAFF]);
  
  // Halo externo
  Draw3DSphere(Bitmap, CenterX, CenterY, 15, [$00AAFFFF, $0066AAFF, $003388DD, $00225588]);
  
  // Efeito de brilho adicional
  Draw3DSphere(Bitmap, CenterX, CenterY, 25, [$0044AAFF, $002288DD, $001166BB, $00004488]);
end;

procedure TSpriteManager.CreateExplosion3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Limpar bitmap
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  // Núcleo da explosão (branco quente)
  Draw3DSphere(Bitmap, CenterX, CenterY, 20, [$00FFFFFF, $00FFFFFF, $00FFFF88, $00FFDD44]);
  
  // Camada intermediária (amarelo-laranja)
  Draw3DSphere(Bitmap, CenterX, CenterY, 35, [$00FFFF00, $00FFAA00, $00FF6600, $00DD4400]);
  
  // Camada externa (vermelho-escuro)
  Draw3DSphere(Bitmap, CenterX, CenterY, 50, [$00FF4400, $00DD2200, $00AA1100, $00770000]);
  
  // Partículas espalhadas
  Draw3DSphere(Bitmap, CenterX - 25, CenterY - 15, 8, [$00FFAA00, $00FF6600, $00DD4400, $00AA2200]);
  Draw3DSphere(Bitmap, CenterX + 30, CenterY - 20, 6, [$00FFAA00, $00FF6600, $00DD4400, $00AA2200]);
  Draw3DSphere(Bitmap, CenterX - 15, CenterY + 25, 10, [$00FFAA00, $00FF6600, $00DD4400, $00AA2200]);
  Draw3DSphere(Bitmap, CenterX + 20, CenterY + 30, 7, [$00FFAA00, $00FF6600, $00DD4400, $00AA2200]);
end;

procedure TSpriteManager.CreateStarfield3D(Bitmap: TBitmap);
var
  i: Integer;
  x, y, size: Integer;
  brightness: Byte;
begin
  // Limpar bitmap
  Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  
  // Criar campo de estrelas aleatório
  for i := 1 to 50 do
  begin
    x := Random(Bitmap.Width);
    y := Random(Bitmap.Height);
    size := Random(3) + 1;
    brightness := Random(128) + 127;
    
    // Estrela com brilho variável
    Draw3DSphere(Bitmap, x, y, size, [RGB(brightness, brightness, brightness), 
                                      RGB(brightness div 2, brightness div 2, brightness div 2),
                                      RGB(brightness div 4, brightness div 4, brightness div 4),
                                      RGB(brightness div 8, brightness div 8, brightness div 8)]);
  end;
end;

end.