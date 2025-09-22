unit Renderer3D;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls, GameObjects;

type
  TRenderer3D = class
  private
    FCanvas: TCanvas;
    FPaintBox: TPaintBox;
    FWidth, FHeight: Integer;
    FCameraZ: Single;
    FProjectionMatrix: array[0..3, 0..3] of Single;
    
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
    
    // Métodos de renderização
    procedure RenderPlayer(Player: TPlayer);
    procedure RenderBullet(Bullet: TBullet);
    procedure RenderEnemy(Enemy: TEnemy);
    procedure RenderAirplane(Airplane: TAirplane);
    procedure RenderParachutist(Parachutist: TParachutist);
    procedure RenderExplosion(Explosion: TExplosion);
    procedure RenderStars(Stars: TGameObjectList<TStar>);
    procedure RenderUI(Score, Lives: Integer);
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
  FCameraZ := 15;
  InitializeProjection;
end;

destructor TRenderer3D.Destroy;
begin
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
  X, Y, Z, W: Single;
  ScreenX, ScreenY: Integer;
begin
  // Transformar ponto 3D para coordenadas da tela
  X := Point3D.X;
  Y := Point3D.Y;
  Z := Point3D.Z - FCameraZ;
  
  if Z <= 0 then
  begin
    // Ponto atrás da câmera
    Result := Point(-1000, -1000);
    Exit;
  end;
  
  // Projeção perspectiva simples
  ScreenX := Round((X / Z) * 300 + FWidth / 2);
  ScreenY := Round((-Y / Z) * 300 + FHeight / 2);
  
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
  // Finalizar renderização (se necessário)
end;

procedure TRenderer3D.RenderPlayer(Player: TPlayer);
var
  Center: TPoint;
  Size: Integer;
begin
  Center := ProjectPoint(Player.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  Size := 30;
  DrawWireframeCube(Center, Size, Player.Color);
end;

procedure TRenderer3D.RenderBullet(Bullet: TBullet);
var
  Center: TPoint;
  Size: Integer;
begin
  Center := ProjectPoint(Bullet.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  Size := 8;
  FCanvas.Pen.Color := Bullet.Color;
  FCanvas.Pen.Width := 3;
  FCanvas.Brush.Color := Bullet.Color;
  FCanvas.Brush.Style := bsSolid;
  FCanvas.Ellipse(Center.X - Size, Center.Y - Size,
                  Center.X + Size, Center.Y + Size);
end;

procedure TRenderer3D.RenderEnemy(Enemy: TEnemy);
var
  Center: TPoint;
  Size: Integer;
begin
  Center := ProjectPoint(Enemy.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  Size := 25;
  DrawWireframeSphere(Center, Size, Enemy.Color);
end;

procedure TRenderer3D.RenderAirplane(Airplane: TAirplane);
var
  Center: TPoint;
  Size: Integer;
begin
  Center := ProjectPoint(Airplane.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  Size := 40;
  
  FCanvas.Pen.Color := Airplane.Color;
  FCanvas.Pen.Width := 2;
  
  // Desenhar corpo do avião
  FCanvas.MoveTo(Center.X - Size, Center.Y);
  FCanvas.LineTo(Center.X + Size, Center.Y);
  
  // Desenhar asas
  FCanvas.MoveTo(Center.X - Size div 2, Center.Y - Size div 3);
  FCanvas.LineTo(Center.X + Size div 2, Center.Y + Size div 3);
end;

procedure TRenderer3D.RenderParachutist(Parachutist: TParachutist);
var
  Center: TPoint;
  Size: Integer;
begin
  Center := ProjectPoint(Parachutist.Position);
  if (Center.X < -500) or (Center.Y < -500) then Exit;
  
  Size := 15;
  
  FCanvas.Pen.Color := Parachutist.Color;
  FCanvas.Pen.Width := 2;
  FCanvas.Brush.Style := bsClear;
  
  if Parachutist.ParachuteOpen then
  begin
    // Desenhar paraquedas
    FCanvas.Ellipse(Center.X - Size * 2, Center.Y - Size * 2,
                    Center.X + Size * 2, Center.Y);
    // Linhas do paraquedas
    FCanvas.MoveTo(Center.X - Size, Center.Y - Size);
    FCanvas.LineTo(Center.X, Center.Y + Size);
    FCanvas.MoveTo(Center.X + Size, Center.Y - Size);
    FCanvas.LineTo(Center.X, Center.Y + Size);
  end;
  
  // Desenhar pessoa
  FCanvas.Ellipse(Center.X - Size div 2, Center.Y + Size - Size div 2,
                  Center.X + Size div 2, Center.Y + Size + Size div 2);
end;

procedure TRenderer3D.RenderExplosion(Explosion: TExplosion);
begin
  DrawExplosion(Explosion);
end;

procedure TRenderer3D.RenderStars(Stars: TGameObjectList<TStar>);
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
      FCanvas.Ellipse(Center.X - 1, Center.Y - 1,
                      Center.X + 1, Center.Y + 1);
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