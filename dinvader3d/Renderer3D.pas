unit Renderer3D;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math, System.UITypes,
  System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls, 
  Winapi.Windows, GameObjects, SpriteManager, EffectsManager;

type
  TRenderer3D = class
  private
    FCanvas: TCanvas;
    FPaintBox: TPaintBox;
    FWidth, FHeight: Integer;
    FCameraZ: Single;
    FProjectionMatrix: array[0..3, 0..3] of Single;
    FSpriteManager: TSpriteManager;
    FEffectsManager: TEffectsManager;
    
    procedure InitializeProjection;
    function ProjectPoint(const Point3D: TVector3D): TPoint;
    procedure DrawWireframeCube(Center: TPoint; Size: Integer; Color: TColor);
    procedure DrawWireframeSphere(Center: TPoint; Radius: Integer; Color: TColor);
    procedure DrawWireframeCone(Center: TPoint; Size: Integer; Color: TColor);
    procedure DrawStarField(Stars: TGameObjectList<TStar>);
    procedure DrawExplosion(Explosion: TExplosion);
  public
    constructor Create(APaintBox: TPaintBox);
    destructor Destroy; override;
    
    procedure Resize(AWidth, AHeight: Integer);
    procedure BeginRender;
    procedure EndRender;
    procedure Update(DeltaTime: Single);
    
    // Métodos de renderização
    procedure RenderPlayer(Player: TPlayer);
    procedure RenderBullet(Bullet: TBullet);
    procedure RenderEnemy(Enemy: TEnemy);
    procedure RenderAirplane(Airplane: TAirplane);
    procedure RenderParachutist(Parachutist: TParachutist);
    procedure RenderExplosion(Explosion: TExplosion);
    procedure RenderStars(Stars: TGameObjectList<TStar>);
    procedure RenderUI(Score, Lives: Integer);
    
    // Propriedade para acesso ao SpriteManager
    property SpriteManager: TSpriteManager read FSpriteManager;
  end;

implementation

{ TRenderer3D }

constructor TRenderer3D.Create(APaintBox: TPaintBox);
begin
  inherited Create;
  FPaintBox := APaintBox;
  FCanvas := FPaintBox.Canvas;
  FWidth := FPaintBox.Width;
  FHeight := FPaintBox.Height;
  FCameraZ := -15;
  
  // Inicializar SpriteManager
  FSpriteManager := TSpriteManager.Create(FCanvas);
  FSpriteManager.LoadSprites;
  
  // Inicializar EffectsManager
  FEffectsManager := TEffectsManager.Create(FCanvas, FWidth, FHeight);
  
  InitializeProjection;
end;

destructor TRenderer3D.Destroy;
begin
  FEffectsManager.Free;
  FSpriteManager.Free;
  inherited Destroy;
end;

procedure TRenderer3D.InitializeProjection;
var
  AspectRatio, FOV, Near, Far: Single;
  f: Single;
begin
  // Configurar matriz de projeção perspectiva
  AspectRatio := FWidth / FHeight;
  FOV := 75 * Pi / 180; // 75 graus em radianos
  Near := 0.1;
  Far := 100.0;
  
  f := 1.0 / Tan(FOV / 2);
  
  // Limpar matriz
  FillChar(FProjectionMatrix, SizeOf(FProjectionMatrix), 0);
  
  // Configurar matriz de projeção
  FProjectionMatrix[0, 0] := f / AspectRatio;
  FProjectionMatrix[1, 1] := f;
  FProjectionMatrix[2, 2] := (Far + Near) / (Near - Far);
  FProjectionMatrix[2, 3] := (2 * Far * Near) / (Near - Far);
  FProjectionMatrix[3, 2] := -1;
end;

function TRenderer3D.ProjectPoint(const Point3D: TVector3D): TPoint;
var
  X, Y, Z: Single;
  ScreenX, ScreenY: Integer;
  PerspectiveFactor: Single;
begin
  // Transformar ponto 3D para coordenadas da tela
  X := Point3D.X;
  Y := Point3D.Y;
  Z := Point3D.Z - FCameraZ;
  
  if Z <= 0.1 then
  begin
    // Ponto muito próximo ou atrás da câmera
    Result := Point(-1000, -1000);
    Exit;
  end;
  
  // Fator de perspectiva mais suave
  PerspectiveFactor := 400.0 / (Z + 5.0); // Adicionar offset para suavizar
  
  // Projeção perspectiva com transição mais suave
  ScreenX := Round(X * PerspectiveFactor + FWidth / 2);
  ScreenY := Round(-Y * PerspectiveFactor + FHeight / 2);
  
  Result := Point(ScreenX, ScreenY);
end;

procedure TRenderer3D.DrawWireframeCube(Center: TPoint; Size: Integer; Color: TColor);
var
  HalfSize: Integer;
  Points: array[0..7] of TPoint;
begin
  HalfSize := Size div 2;
  
  // Definir vértices do cubo (projeção 2D simplificada)
  Points[0] := Point(Center.X - HalfSize, Center.Y - HalfSize); // Front bottom left
  Points[1] := Point(Center.X + HalfSize, Center.Y - HalfSize); // Front bottom right
  Points[2] := Point(Center.X + HalfSize, Center.Y + HalfSize); // Front top right
  Points[3] := Point(Center.X - HalfSize, Center.Y + HalfSize); // Front top left
  Points[4] := Point(Center.X - HalfSize - 10, Center.Y - HalfSize - 10); // Back bottom left
  Points[5] := Point(Center.X + HalfSize - 10, Center.Y - HalfSize - 10); // Back bottom right
  Points[6] := Point(Center.X + HalfSize - 10, Center.Y + HalfSize - 10); // Back top right
  Points[7] := Point(Center.X - HalfSize - 10, Center.Y + HalfSize - 10); // Back top left
  
  FCanvas.Pen.Color := Color;
  FCanvas.Pen.Width := 2;
  
  // Desenhar faces frontais
  FCanvas.MoveTo(Points[0].X, Points[0].Y);
  FCanvas.LineTo(Points[1].X, Points[1].Y);
  FCanvas.LineTo(Points[2].X, Points[2].Y);
  FCanvas.LineTo(Points[3].X, Points[3].Y);
  FCanvas.LineTo(Points[0].X, Points[0].Y);
  
  // Desenhar faces traseiras
  FCanvas.MoveTo(Points[4].X, Points[4].Y);
  FCanvas.LineTo(Points[5].X, Points[5].Y);
  FCanvas.LineTo(Points[6].X, Points[6].Y);
  FCanvas.LineTo(Points[7].X, Points[7].Y);
  FCanvas.LineTo(Points[4].X, Points[4].Y);
  
  // Conectar frente e trás
  FCanvas.MoveTo(Points[0].X, Points[0].Y);
  FCanvas.LineTo(Points[4].X, Points[4].Y);
  FCanvas.MoveTo(Points[1].X, Points[1].Y);
  FCanvas.LineTo(Points[5].X, Points[5].Y);
  FCanvas.MoveTo(Points[2].X, Points[2].Y);
  FCanvas.LineTo(Points[6].X, Points[6].Y);
  FCanvas.MoveTo(Points[3].X, Points[3].Y);
  FCanvas.LineTo(Points[7].X, Points[7].Y);
end;

procedure TRenderer3D.DrawWireframeSphere(Center: TPoint; Radius: Integer; Color: TColor);
var
  i: Integer;
  Angle: Single;
  X, Y: Integer;
begin
  FCanvas.Pen.Color := Color;
  FCanvas.Pen.Width := 2;
  FCanvas.Brush.Style := bsClear;
  
  // Desenhar círculo principal
  FCanvas.Ellipse(Center.X - Radius, Center.Y - Radius,
                  Center.X + Radius, Center.Y + Radius);
  
  // Desenhar linhas de longitude
  for i := 0 to 3 do
  begin
    Angle := i * Pi / 2;
    X := Round(Radius * Cos(Angle));
    Y := Round(Radius * Sin(Angle) * 0.5); // Achatado para dar efeito 3D
    FCanvas.MoveTo(Center.X - X, Center.Y - Y);
    FCanvas.LineTo(Center.X + X, Center.Y + Y);
  end;
end;

procedure TRenderer3D.DrawWireframeCone(Center: TPoint; Size: Integer; Color: TColor);
var
  BaseRadius: Integer;
  TipY: Integer;
  i: Integer;
  Angle: Single;
  X, Y: Integer;
begin
  BaseRadius := Size;
  TipY := Center.Y - Size;
  
  FCanvas.Pen.Color := Color;
  FCanvas.Pen.Width := 2;
  
  // Desenhar base do cone
  FCanvas.Ellipse(Center.X - BaseRadius, Center.Y - BaseRadius div 4,
                  Center.X + BaseRadius, Center.Y + BaseRadius div 4);
  
  // Desenhar linhas do cone
  for i := 0 to 7 do
  begin
    Angle := i * 2 * Pi / 8;
    X := Round(BaseRadius * Cos(Angle));
    Y := Round(BaseRadius * Sin(Angle) * 0.25);
    FCanvas.MoveTo(Center.X + X, Center.Y + Y);
    FCanvas.LineTo(Center.X, TipY);
  end;
end;

procedure TRenderer3D.DrawExplosion(Explosion: TExplosion);
var
  Center: TPoint;
  i, Radius: Integer;
  Angle: Single;
  X, Y: Integer;
  Alpha: Single;
begin
  Center := ProjectPoint(Explosion.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  Alpha := 1.0 - (Explosion.LifeTime / Explosion.MaxLifeTime);
  Radius := Round(Explosion.Size * 10);
  
  FCanvas.Pen.Color := clYellow;
  FCanvas.Pen.Width := 3;
  
  // Desenhar raios da explosão
  for i := 0 to 11 do
  begin
    Angle := i * 2 * Pi / 12;
    X := Round(Radius * Cos(Angle) * Alpha);
    Y := Round(Radius * Sin(Angle) * Alpha);
    FCanvas.MoveTo(Center.X, Center.Y);
    FCanvas.LineTo(Center.X + X, Center.Y + Y);
  end;
  
  // Desenhar círculo central
  FCanvas.Pen.Color := clRed;
  FCanvas.Brush.Style := bsClear;
  FCanvas.Ellipse(Center.X - Radius div 3, Center.Y - Radius div 3,
                  Center.X + Radius div 3, Center.Y + Radius div 3);
end;

procedure TRenderer3D.DrawStarField(Stars: TGameObjectList<TStar>);
var
  i: Integer;
  Center: TPoint;
  Star: TStar;
begin
  FCanvas.Pen.Color := clWhite;
  FCanvas.Pen.Width := 1;
  FCanvas.Brush.Color := clWhite;
  FCanvas.Brush.Style := bsSolid;
  
  for i := 0 to Stars.Count - 1 do
  begin
    Star := Stars[i];
    Center := ProjectPoint(Star.Position);
    if (Center.X >= 0) and (Center.X < FWidth) and 
       (Center.Y >= 0) and (Center.Y < FHeight) then
    begin
      FCanvas.Ellipse(Center.X - 1, Center.Y - 1, Center.X + 1, Center.Y + 1);
    end;
  end;
end;

procedure TRenderer3D.Resize(AWidth, AHeight: Integer);
begin
  FWidth := AWidth;
  FHeight := AHeight;
  InitializeProjection;
end;

procedure TRenderer3D.BeginRender;
begin
  // Limpar tela
  FCanvas.Brush.Color := clBlack;
  FCanvas.Brush.Style := bsSolid;
  FCanvas.FillRect(Rect(0, 0, FWidth, FHeight));
end;

procedure TRenderer3D.EndRender;
begin
  // Renderizar efeitos especiais por último
  FEffectsManager.Render;
  
  // Finalizar renderização (se necessário)
end;

procedure TRenderer3D.Update(DeltaTime: Single);
begin
  // Atualizar sistema de efeitos especiais
  FEffectsManager.Update(DeltaTime);
end;

procedure TRenderer3D.RenderPlayer(Player: TPlayer);
var
  Center: TPoint;
  Scale: Single;
begin
  Center := ProjectPoint(Player.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  // Calcular escala baseada na distância Z com transição mais suave
  Scale := 1.0 + (Player.Position.Z + 15.0) / 20.0;
  Scale := Max(0.5, Min(2.5, Scale)); // Limitar escala
  
  // Adicionar efeito de propulsão
  FEffectsManager.AddEngineFlame(Player.Position.X, Player.Position.Y + 15, Player.Position.Z,
                                Player.Velocity.X, Player.Velocity.Y, Player.Velocity.Z);
  
  // Desenhar sprite 3D do robô jogador
  FSpriteManager.DrawSprite(stPlayerRobot, Center.X, Center.Y, Scale, 0, 255);
end;

procedure TRenderer3D.RenderBullet(Bullet: TBullet);
var
  Center: TPoint;
  Scale: Single;
begin
  Center := ProjectPoint(Bullet.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  // Calcular escala baseada na distância Z com transição mais suave
  Scale := 0.5 + (Bullet.Position.Z + 15.0) / 25.0;
  Scale := Max(0.3, Min(1.2, Scale)); // Limitar escala para projéteis
  
  // Adicionar rastro de energia
  FEffectsManager.AddLaserTrail(Bullet.Position.X, Bullet.Position.Y, Bullet.Position.Z,
                               Bullet.Velocity.X, Bullet.Velocity.Y, Bullet.Velocity.Z);
  
  // Escolher sprite baseado no tipo de projétil
  if Bullet.IsPlayerBullet then
    FSpriteManager.DrawSprite(stLaserBeam, Center.X, Center.Y, Scale, 0, 255)
  else
    FSpriteManager.DrawSprite(stLaserBeam, Center.X, Center.Y, Scale, 0, 200); // Projéteis inimigos mais transparentes
end;

procedure TRenderer3D.RenderEnemy(Enemy: TEnemy);
var
  Center: TPoint;
  Scale: Single;
  Frame: Integer;
begin
  Center := ProjectPoint(Enemy.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  // Calcular escala baseada na distância Z com transição mais suave
  Scale := 1.0 + (Enemy.Position.Z + 15.0) / 18.0;
  Scale := Max(0.6, Min(2.2, Scale)); // Limitar escala
  
  // Frame de animação baseado no tempo
  Frame := Round(GetTickCount / 100) mod 360;
  
  // Adicionar campo de energia ao redor do UFO
  FEffectsManager.AddEnergyField(Enemy.Position.X, Enemy.Position.Y, Enemy.Position.Z);
  
  // Adicionar brilho
  FEffectsManager.AddGlow(Enemy.Position.X, Enemy.Position.Y, Enemy.Position.Z, 
                         RGB(0, 255, 255), 0.5);
  
  // Desenhar sprite 3D do UFO clássico com animação
  FSpriteManager.DrawAnimatedSprite(stUfoClassic, Center.X, Center.Y, Frame, Scale, 0, 255);
end;

procedure TRenderer3D.RenderAirplane(Airplane: TAirplane);
var
  Center: TPoint;
  Scale: Single;
  Rotation: Single;
begin
  Center := ProjectPoint(Airplane.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  // Calcular escala baseada na distância Z com transição mais suave
  Scale := 1.0 + (Airplane.Position.Z + 15.0) / 18.0;
  Scale := Max(0.5, Min(2.0, Scale)); // Limitar escala
  
  // Rotação baseada na velocidade
  Rotation := 0;
  
  // Adicionar chamas dos motores
  FEffectsManager.AddEngineFlame(Airplane.Position.X - 20, Airplane.Position.Y, Airplane.Position.Z,
                                Airplane.Velocity.X, Airplane.Velocity.Y, Airplane.Velocity.Z);
  
  // Desenhar sprite 3D da nave de combate
  FSpriteManager.DrawSprite(stFighterJet, Center.X, Center.Y, Scale, Rotation, 255);
end;

procedure TRenderer3D.RenderParachutist(Parachutist: TParachutist);
var
  Center: TPoint;
  Scale: Single;
  Frame: Integer;
begin
  Center := ProjectPoint(Parachutist.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  // Calcular escala baseada na distância Z com transição mais suave
  Scale := 0.8 + (Parachutist.Position.Z + 15.0) / 20.0;
  Scale := Max(0.4, Min(1.8, Scale)); // Limitar escala
  
  // Frame de animação para movimento do paraquedas
  Frame := Round(GetTickCount / 150) mod 360;
  
  // Desenhar sprite 3D do paraquedista
  if Parachutist.ParachuteOpen then
    FSpriteManager.DrawAnimatedSprite(stParatrooper, Center.X, Center.Y, Frame, Scale, 0, 255)
  else
    FSpriteManager.DrawSprite(stParatrooper, Center.X, Center.Y, Scale * 0.7, 0, 255);
end;

procedure TRenderer3D.RenderExplosion(Explosion: TExplosion);
var
  Center: TPoint;
  Scale: Single;
  Frame: Integer;
  Alpha: Byte;
  Intensity: Single;
  FlashEffect: Boolean;
begin
  Center := ProjectPoint(Explosion.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  // Calcular intensidade da explosão baseada no tempo de vida
  Intensity := 1.0 - (Explosion.LifeTime / Explosion.MaxLifeTime);
  
  // Efeito de flash inicial para tornar a explosão mais visível
  FlashEffect := Explosion.LifeTime < (Explosion.MaxLifeTime * 0.2); // Primeiros 20%
  
  // Calcular escala da explosão (cresce rapidamente no início)
  if FlashEffect then
    Scale := 3.0 + Intensity * 2.0  // Explosão grande e brilhante no início
  else
    Scale := 2.0 + (1.0 - Intensity) * 1.5; // Diminui gradualmente
  
  // Calcular transparência
  if FlashEffect then
    Alpha := 255  // Totalmente opaco no flash inicial
  else
    Alpha := Round(Intensity * 200); // Fade out gradual
  
  // Frame de animação para efeito dinâmico
  Frame := Round((1.0 - Intensity) * 360);
  
  // Adicionar múltiplos efeitos visuais para maior impacto
  if FlashEffect then
  begin
    // Onda de choque inicial
    FEffectsManager.AddShockwave(Explosion.Position.X, Explosion.Position.Y, Explosion.Position.Z, 
                                Scale * 50.0);
    
    // Campo de energia para efeito de flash
    FEffectsManager.AddEnergyField(Explosion.Position.X, Explosion.Position.Y, Explosion.Position.Z);
  end;
  
  // Adicionar explosão principal com intensidade alta
  FEffectsManager.AddExplosion(Explosion.Position.X, Explosion.Position.Y, Explosion.Position.Z, 
                              Intensity * 2.0);
  
  // Adicionar brilho ao redor da explosão
  FEffectsManager.AddGlow(Explosion.Position.X, Explosion.Position.Y, Explosion.Position.Z, 
                         RGB(255, 128, 0), Intensity);
  
  // Desenhar múltiplos sprites da explosão para maior impacto visual
  FSpriteManager.DrawAnimatedSprite(stExplosionParticle, Center.X, Center.Y, Frame, Scale, 0, Alpha);
  
  // Adicionar sprites secundários para efeito mais dramático
  if FlashEffect then
  begin
    FSpriteManager.DrawAnimatedSprite(stExplosionParticle, Center.X - 15, Center.Y - 15, 
                                     Frame + 90, Scale * 0.8, 45, Alpha);
    FSpriteManager.DrawAnimatedSprite(stExplosionParticle, Center.X + 15, Center.Y + 15, 
                                     Frame + 180, Scale * 0.6, 90, Alpha);
  end;
end;

procedure TRenderer3D.RenderStars(Stars: TGameObjectList<TStar>);
var
  i: Integer;
  Center: TPoint;
  Star: TStar;
  Scale: Single;
  Alpha: Byte;
begin
  // Desenhar fundo de campo de estrelas primeiro
  FSpriteManager.DrawSprite(stStarfieldBg, FWidth div 2, FHeight div 2, 1.0, 0, 128);
  
  // Desenhar estrelas individuais com brilho
  for i := 0 to Stars.Count - 1 do
  begin
    Star := Stars[i];
    Center := ProjectPoint(Star.Position);
    if (Center.X >= 0) and (Center.X < FWidth) and 
       (Center.Y >= 0) and (Center.Y < FHeight) then
    begin
      // Escala baseada na distância Z
      Scale := 0.1 + (Star.Position.Z / 50.0);
      Scale := Max(0.05, Min(0.3, Scale));
      
      // Alpha baseado na distância para efeito de profundidade
      Alpha := Round(255 * Scale / 0.3);
      Alpha := Max(100, Min(255, Alpha));
      
      // Desenhar estrela com brilho
      FCanvas.Pen.Color := RGB(255, 255, 200 + Random(55));
      FCanvas.Pen.Width := 1;
      FCanvas.Brush.Color := FCanvas.Pen.Color;
      FCanvas.Brush.Style := bsSolid;
      
      // Estrela principal
      FCanvas.Ellipse(Center.X - Round(Scale * 10), Center.Y - Round(Scale * 10),
                      Center.X + Round(Scale * 10), Center.Y + Round(Scale * 10));
      
      // Efeito de brilho ocasional
      if Random(10) = 0 then
      begin
        FCanvas.Pen.Color := RGB(255, 255, 255);
        FCanvas.MoveTo(Center.X - Round(Scale * 15), Center.Y);
        FCanvas.LineTo(Center.X + Round(Scale * 15), Center.Y);
        FCanvas.MoveTo(Center.X, Center.Y - Round(Scale * 15));
        FCanvas.LineTo(Center.X, Center.Y + Round(Scale * 15));
        
        // Adicionar efeito de cintilação com partículas
        FEffectsManager.AddStarTwinkle(Star.Position.X, Star.Position.Y, Star.Position.Z);
      end;
    end;
  end;
end;

procedure TRenderer3D.RenderUI(Score, Lives: Integer);
begin
  FCanvas.Font.Color := clWhite;
  FCanvas.Font.Size := 12;
  FCanvas.Font.Style := [fsBold];
  FCanvas.Brush.Style := bsClear;
  
  // Desenhar informações na tela
  FCanvas.TextOut(10, 10, 'Score: ' + IntToStr(Score));
  FCanvas.TextOut(10, 30, 'Lives: ' + IntToStr(Lives));
  
  // Desenhar mira no centro
  FCanvas.Pen.Color := clGreen;
  FCanvas.Pen.Width := 1;
  FCanvas.MoveTo(FWidth div 2 - 10, FHeight div 2);
  FCanvas.LineTo(FWidth div 2 + 10, FHeight div 2);
  FCanvas.MoveTo(FWidth div 2, FHeight div 2 - 10);
  FCanvas.LineTo(FWidth div 2, FHeight div 2 + 10);
end;

end.