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
      const Colors: array of TColor; ClearBackground: Boolean = True);
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
    
    // Método simples para teste de sprite
    procedure TestDrawSprite(X, Y: Integer);
    
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
            Draw3DSphere(Result, 64, 64, 50, [$00FFFFFF, $00AAAAFF, $004488CC, $00224466])
          else if ResourceName = 'UFO_CLASSIC' then
            Draw3DSphere(Result, 64, 64, 55, [$00CCCCCC, $00888888, $00444444, $00222222])
          else if ResourceName = 'FIGHTER_JET' then
            Draw3DSphere(Result, 64, 64, 45, [$00DDDDDD, $00999999, $00555555, $00333333])
          else if ResourceName = 'PARATROOPER' then
            Draw3DSphere(Result, 64, 64, 40, [$0088AA88, $00556655, $00334433, $00223322])
          else if ResourceName = 'LASER_BEAM' then
            Draw3DSphere(Result, 64, 64, 25, [$00FFFFFF, $00AAFFFF, $0000FFFF, $000088FF])
          else if ResourceName = 'EXPLOSION_PARTICLE' then
            Draw3DSphere(Result, 64, 64, 60, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400])
          else
            Draw3DSphere(Result, 64, 64, 50, [$00FFFFFF, $00CCCCCC, $00888888, $00444444]);
        end;
      end
      else
      begin
        // Se não encontrar arquivo SVG, usar sprite 3D procedural
        Result.Width := 128;
        Result.Height := 128;
        Result.PixelFormat := pf32bit;
        
        if ResourceName = 'PLAYER_ROBOT' then
          Draw3DSphere(Result, 64, 64, 50, [$00FFFFFF, $00AAAAFF, $004488CC, $00224466])
        else if ResourceName = 'UFO_CLASSIC' then
          Draw3DSphere(Result, 64, 64, 55, [$00CCCCCC, $00888888, $00444444, $00222222])
        else if ResourceName = 'FIGHTER_JET' then
          Draw3DSphere(Result, 64, 64, 45, [$00DDDDDD, $00999999, $00555555, $00333333])
        else if ResourceName = 'PARATROOPER' then
          Draw3DSphere(Result, 64, 64, 40, [$0088AA88, $00556655, $00334433, $00223322])
        else if ResourceName = 'LASER_BEAM' then
          Draw3DSphere(Result, 64, 64, 25, [$00FFFFFF, $00AAFFFF, $0000FFFF, $000088FF])
        else if ResourceName = 'EXPLOSION_PARTICLE' then
          Draw3DSphere(Result, 64, 64, 60, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400])
        else
          Draw3DSphere(Result, 64, 64, 50, [$00FFFFFF, $00CCCCCC, $00888888, $00444444]);
      end;
    end;
  end;
end;

function TSpriteManager.SVGToBitmap(const SVGData: string; Width, Height: Integer; const ResourceName: string): TBitmap;
var
  centerX, centerY: Integer;
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
    Draw3DSphere(Result, centerX, centerY, 50, [$00FFFFFF, $00CCCCCC, $00888888, $00444444]);
  end;
end;

procedure TSpriteManager.Draw3DSphere(Bitmap: TBitmap; X, Y, Radius: Integer; 
  const Colors: array of TColor; ClearBackground: Boolean = True);
var
  i, j: Integer;
  dx, dy, distance: Single;
  normalizedDist: Single;
  colorIndex: Integer;
  r1, g1, b1, r2, g2, b2: Byte;
  finalR, finalG, finalB: Byte;
  blend: Single;
  pixelColor: TColor;
  highlight: Single;
  shadow: Single;
  specular: Single;
begin
  // Limpar bitmap apenas se solicitado (primeira chamada)
  if ClearBackground then
  begin
    Bitmap.Canvas.Brush.Color := clBlack;
    Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  end;
  
  // Usar BeginUpdate/EndUpdate para melhor performance
  Bitmap.Canvas.Lock;
  try
    for j := 0 to Bitmap.Height - 1 do
    begin
      for i := 0 to Bitmap.Width - 1 do
      begin
        dx := i - X;
        dy := j - Y;
        distance := Sqrt(dx * dx + dy * dy);
        
        if distance <= Radius then
        begin
          // Calcular iluminação 3D
          normalizedDist := distance / Radius;
          
          // Calcular efeitos 3D avançados
          // Highlight (brilho no topo-esquerda)
          highlight := Max(0, 1 - Sqrt((dx + Radius * 0.3) * (dx + Radius * 0.3) + 
                                      (dy + Radius * 0.3) * (dy + Radius * 0.3)) / (Radius * 0.6));
          
          // Shadow (sombra no fundo-direita)
          shadow := Max(0, 1 - Sqrt((dx - Radius * 0.4) * (dx - Radius * 0.4) + 
                                   (dy - Radius * 0.4) * (dy - Radius * 0.4)) / (Radius * 0.5));
          
          // Specular highlight (reflexo especular)
          specular := Max(0, 1 - Sqrt((dx + Radius * 0.2) * (dx + Radius * 0.2) + 
                                     (dy + Radius * 0.2) * (dy + Radius * 0.2)) / (Radius * 0.3));
          specular := Power(specular, 4); // Reflexo mais concentrado
          
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
          
          // Aplicar efeitos 3D
          // Highlight
          finalR := Min(255, Round(finalR + highlight * 80));
          finalG := Min(255, Round(finalG + highlight * 80));
          finalB := Min(255, Round(finalB + highlight * 80));
          
          // Shadow
          finalR := Max(0, Round(finalR - shadow * 60));
          finalG := Max(0, Round(finalG - shadow * 60));
          finalB := Max(0, Round(finalB - shadow * 60));
          
          // Specular highlight
          finalR := Min(255, Round(finalR + specular * 120));
          finalG := Min(255, Round(finalG + specular * 120));
          finalB := Min(255, Round(finalB + specular * 120));
          
          // Anti-aliasing nas bordas
          if normalizedDist > 0.85 then
          begin
            blend := (1.0 - normalizedDist) / 0.15;
            finalR := Round(finalR * blend);
            finalG := Round(finalG * blend);
            finalB := Round(finalB * blend);
          end;
          
          pixelColor := RGB(finalR, finalG, finalB);
          
          // Definir pixel usando Canvas.Pixels com Lock/Unlock
          Bitmap.Canvas.Pixels[i, j] := pixelColor;
        end;
      end;
    end;
  finally
    Bitmap.Canvas.Unlock;
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
  
  // Configurar transparência - preto (RGB(0,0,0)) será transparente
  Bitmap.Transparent := True;
  Bitmap.TransparentColor := clBlack;
  Bitmap.TransparentMode := tmFixed;
  
  // Aplicar transparência se necessário
  if Alpha < 255 then
  begin
    // Para alpha blending, usar modo de cópia com transparência
    FCanvas.CopyMode := cmSrcCopy;
  end
  else
  begin
    // Modo normal com transparência
    FCanvas.CopyMode := cmSrcCopy;
  end;
  
  // Desenhar sprite com transparência
  FCanvas.StretchDraw(DestRect, Bitmap);
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
  // Corpo principal do robô (esfera azul metálica) - limpar fundo na primeira chamada
  Draw3DSphere(Bitmap, CenterX, CenterY, 35, [$0000AAFF, $000088CC, $00006699, $00004466], True);
  
  // Cabeça robótica (menor, acima do corpo) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX, CenterY - 25, 18, [$00CCCCCC, $00999999, $00666666, $00333333], False);
  
  // Olhos brilhantes (pequenos pontos vermelhos) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 8, CenterY - 28, 4, [$00FFFFFF, $00FF4444, $00CC0000, $00880000], False);
  Draw3DSphere(Bitmap, CenterX + 8, CenterY - 28, 4, [$00FFFFFF, $00FF4444, $00CC0000, $00880000], False);
  
  // Braços robóticos (esferas menores nas laterais) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 30, CenterY - 5, 12, [$00888888, $00666666, $00444444, $00222222], False);
  Draw3DSphere(Bitmap, CenterX + 30, CenterY - 5, 12, [$00888888, $00666666, $00444444, $00222222], False);
  
  // Jatos propulsores (esferas alaranjadas embaixo) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 15, CenterY + 35, 8, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400], False);
  Draw3DSphere(Bitmap, CenterX + 15, CenterY + 35, 8, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400], False);
  
  // Antena no topo da cabeça - não limpar fundo
  Draw3DSphere(Bitmap, CenterX, CenterY - 40, 3, [$00FFFFFF, $00AAAAAA, $00666666, $00333333], False);
  
  // Detalhes no peito (luzes de status) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 8, CenterY - 8, 3, [$00FFFFFF, $0000FF00, $0000AA00, $00006600], False);
  Draw3DSphere(Bitmap, CenterX + 8, CenterY - 8, 3, [$00FFFFFF, $0000FF00, $0000AA00, $00006600], False);
end;

procedure TSpriteManager.CreateUFO3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Corpo principal do UFO (disco achatado) - limpar fundo na primeira chamada
  Draw3DSphere(Bitmap, CenterX, CenterY + 5, 45, [$00CCCCCC, $00888888, $00444444, $00222222], True);
  
  // Cúpula superior transparente - não limpar fundo
  Draw3DSphere(Bitmap, CenterX, CenterY - 10, 25, [$00FFFFFF, $00AAFFFF, $004488CC, $00224466], False);
  
  // Luzes coloridas ao redor do disco (mais brilhantes) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 35, CenterY + 5, 8, [$00FFFFFF, $00FF6666, $00CC0000, $00880000], False);
  Draw3DSphere(Bitmap, CenterX - 12, CenterY + 15, 8, [$00FFFFFF, $0066FF66, $0000CC00, $00008800], False);
  Draw3DSphere(Bitmap, CenterX + 12, CenterY + 15, 8, [$00FFFFFF, $006666FF, $000000CC, $00000088], False);
  Draw3DSphere(Bitmap, CenterX + 35, CenterY + 5, 8, [$00FFFFFF, $00FFFF66, $00CCCC00, $00888800], False);
  
  // Raio trator (opcional) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX, CenterY + 35, 15, [$00FFFFFF, $00AAFFFF, $0044AAFF, $00226688], False);
  
  // Detalhes adicionais no disco
  Draw3DSphere(Bitmap, CenterX - 20, CenterY + 8, 4, [$00FFFFFF, $00CCCCCC, $00888888, $00444444], False);
  Draw3DSphere(Bitmap, CenterX + 20, CenterY + 8, 4, [$00FFFFFF, $00CCCCCC, $00888888, $00444444], False);
  
  // Antenas pequenas na cúpula
  Draw3DSphere(Bitmap, CenterX - 10, CenterY - 20, 2, [$00FFFFFF, $00AAAAAA, $00666666, $00333333], False);
  Draw3DSphere(Bitmap, CenterX + 10, CenterY - 20, 2, [$00FFFFFF, $00AAAAAA, $00666666, $00333333], False);
end;

procedure TSpriteManager.CreateFighterJet3D(Bitmap: TBitmap; CenterX, CenterY: Integer);
begin
  // Fuselagem principal - limpar fundo na primeira chamada
  Draw3DSphere(Bitmap, CenterX, CenterY, 30, [$00DDDDDD, $00999999, $00555555, $00333333], True);
  
  // Cockpit (vidro azulado) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX, CenterY - 15, 18, [$00FFFFFF, $00AAFFFF, $0066AADD, $00335577], False);
  
  // Asas laterais - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 35, CenterY + 10, 20, [$00BBBBBB, $00888888, $00444444, $00222222], False);
  Draw3DSphere(Bitmap, CenterX + 35, CenterY + 10, 20, [$00BBBBBB, $00888888, $00444444, $00222222], False);
  
  // Motores/Jatos (chamas) - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 20, CenterY + 35, 10, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400], False);
  Draw3DSphere(Bitmap, CenterX + 20, CenterY + 35, 10, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400], False);
  
  // Nariz pontudo - não limpar fundo
  Draw3DSphere(Bitmap, CenterX, CenterY - 35, 8, [$00AAAAAA, $00777777, $00444444, $00222222], False);
  
  // Luzes de navegação - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 40, CenterY + 5, 3, [$00FFFFFF, $00FF0000, $00AA0000, $00660000], False);
  Draw3DSphere(Bitmap, CenterX + 40, CenterY + 5, 3, [$00FFFFFF, $0000FF00, $0000AA00, $00006600], False);
  
  // Armamentos nas asas - não limpar fundo
  Draw3DSphere(Bitmap, CenterX - 25, CenterY + 15, 4, [$00666666, $00444444, $00222222, $00111111], False);
  Draw3DSphere(Bitmap, CenterX + 25, CenterY + 15, 4, [$00666666, $00444444, $00222222, $00111111], False);
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

procedure TSpriteManager.TestDrawSprite(X, Y: Integer);
var
  TestBitmap: TBitmap;
  FileStream: TFileStream;
  SVGText: string;
  SVGBytes: TBytes;
begin
  TestBitmap := TBitmap.Create;
  try
    TestBitmap.Width := 64;
    TestBitmap.Height := 64;
    TestBitmap.PixelFormat := pf32bit;
    
    // Tentar carregar SVG do arquivo
    try
      if FileExists('player_robot.svg') then
      begin
        FileStream := TFileStream.Create('player_robot.svg', fmOpenRead);
        try
          SetLength(SVGBytes, FileStream.Size);
          FileStream.ReadBuffer(SVGBytes[0], FileStream.Size);
          SVGText := TEncoding.UTF8.GetString(SVGBytes);
          
          // Desenhar um retângulo simples como teste
          TestBitmap.Canvas.Brush.Color := clLime;
          TestBitmap.Canvas.FillRect(Rect(10, 10, 54, 54));
          TestBitmap.Canvas.Brush.Color := clRed;
          TestBitmap.Canvas.FillRect(Rect(20, 20, 44, 44));
        finally
          FileStream.Free;
        end;
      end
      else
      begin
        // Se não encontrar arquivo, criar sprite 3D simples
        CreateRobot3D(TestBitmap, 32, 32);
      end;
    except
      // Em caso de erro, desenhar retângulo colorido
      TestBitmap.Canvas.Brush.Color := clYellow;
      TestBitmap.Canvas.FillRect(Rect(0, 0, 64, 64));
      TestBitmap.Canvas.Brush.Color := clBlue;
      TestBitmap.Canvas.FillRect(Rect(16, 16, 48, 48));
    end;
    
    // Desenhar o sprite na tela
    FCanvas.Draw(X, Y, TestBitmap);
  finally
    TestBitmap.Free;
  end;
end;

end.