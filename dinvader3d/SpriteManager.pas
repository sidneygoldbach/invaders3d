unit SpriteManager;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Graphics, System.SysUtils, System.Math;

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
    function SVGToBitmap(const SVGData: string; Width, Height: Integer): TBitmap;
    procedure CreateGradientBitmap(Bitmap: TBitmap; const Colors: array of TColor; 
      CenterX, CenterY, Radius: Integer);
    procedure Draw3DSphere(Bitmap: TBitmap; X, Y, Radius: Integer; 
      const Colors: array of TColor);
    procedure DrawGlowEffect(Bitmap: TBitmap; X, Y, Radius: Integer; 
      Color: TColor; Intensity: Single);
      
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
begin
  Result := TBitmap.Create;
  
  try
    // Carregar SVG do recurso
    ResourceStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
    try
      StringList := TStringList.Create;
      try
        StringList.LoadFromStream(ResourceStream);
        SVGData := StringList.Text;
        
        // Converter SVG para bitmap (implementação simplificada)
        Result := SVGToBitmap(SVGData, 128, 128);
        
      finally
        StringList.Free;
      end;
    finally
      ResourceStream.Free;
    end;
    
  except
    on E: Exception do
    begin
      // Se falhar ao carregar SVG, criar sprite 3D procedural
      Result.Width := 128;
      Result.Height := 128;
      Result.PixelFormat := pf32bit;
      
      // Criar sprite 3D baseado no tipo
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

function TSpriteManager.SVGToBitmap(const SVGData: string; Width, Height: Integer): TBitmap;
begin
  // Implementação simplificada - na prática, seria necessário um parser SVG completo
  // Por enquanto, vamos criar sprites 3D procedurais baseados no conteúdo SVG
  
  Result := TBitmap.Create;
  Result.Width := Width;
  Result.Height := Height;
  Result.PixelFormat := pf32bit;
  
  // Analisar o SVG e criar sprite correspondente
  if Pos('player_robot', SVGData) > 0 then
    Draw3DSphere(Result, Width div 2, Height div 2, 30, [$00FFFFFF, $00AAAAFF, $004488CC, $00224466])
  else if Pos('ufo_classic', SVGData) > 0 then
    Draw3DSphere(Result, Width div 2, Height div 2, 35, [$00CCCCCC, $00888888, $00444444, $00222222])
  else if Pos('fighter_jet', SVGData) > 0 then
    Draw3DSphere(Result, Width div 2, Height div 2, 25, [$00DDDDDD, $00999999, $00555555, $00333333])
  else if Pos('paratrooper', SVGData) > 0 then
    Draw3DSphere(Result, Width div 2, Height div 2, 20, [$0088AA88, $00556655, $00334433, $00223322])
  else if Pos('laser_beam', SVGData) > 0 then
    Draw3DSphere(Result, Width div 2, Height div 2, 15, [$00FFFFFF, $00AAFFFF, $0000FFFF, $000088FF])
  else if Pos('explosion_particle', SVGData) > 0 then
    Draw3DSphere(Result, Width div 2, Height div 2, 40, [$00FFFFFF, $00FFFF00, $00FF8800, $00FF4400])
  else
    Draw3DSphere(Result, Width div 2, Height div 2, 32, [$00FFFFFF, $00CCCCCC, $00888888, $00444444]);
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

end.