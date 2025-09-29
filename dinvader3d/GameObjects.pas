unit GameObjects;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math, System.UITypes,
  Vcl.Graphics, System.Generics.Collections, Winapi.Windows;

type
  // Estruturas básicas
  TVector3D = record
    X, Y, Z: Single;
    constructor Create(AX, AY, AZ: Single);
    function Add(const Other: TVector3D): TVector3D;
    function Subtract(const Other: TVector3D): TVector3D;
    function Multiply(Factor: Single): TVector3D;
    function Distance(const Other: TVector3D): Single;
  end;

  TGameKeys = record
    Left: Boolean;
    Right: Boolean;
    Space: Boolean;
  end;

  // Classe base para objetos do jogo
  TGameObject = class
  private
    FPosition: TVector3D;
    FVelocity: TVector3D;
    FSize: Single;
    FActive: Boolean;
    FColor: TColor;
  public
    constructor Create(APosition: TVector3D; ASize: Single; AColor: TColor);
    procedure Update(DeltaTime: Single); virtual;
    procedure Move(DeltaTime: Single);
    function CheckCollision(Other: TGameObject): Boolean;
    
    property Position: TVector3D read FPosition write FPosition;
    property Velocity: TVector3D read FVelocity write FVelocity;
    property Size: Single read FSize write FSize;
    property Active: Boolean read FActive write FActive;
    property Color: TColor read FColor write FColor;
  end;

  // Jogador
  TPlayer = class(TGameObject)
  private
    FHits: Integer;
    FColorIndex: Integer;
    FColors: array[0..2] of TColor;
    FLastShot: Cardinal;
    FShotCooldown: Cardinal;
  public
    constructor Create(APosition: TVector3D);
    procedure Update(DeltaTime: Single); override;
    procedure Hit;
    function CanShoot: Boolean;
    procedure Shoot;
    procedure UpdateColor;
    
    property Hits: Integer read FHits;
    property ColorIndex: Integer read FColorIndex;
  end;

  // Projétil
  TBullet = class(TGameObject)
  private
    FIsPlayerBullet: Boolean;
  public
    constructor Create(APosition: TVector3D; AIsPlayerBullet: Boolean);
    procedure Update(DeltaTime: Single); override;
    
    property IsPlayerBullet: Boolean read FIsPlayerBullet;
  end;

  // Projétil com alvo específico
  TBulletWithTarget = class(TBullet)
  public
    constructor Create(APosition: TVector3D; AIsPlayerBullet: Boolean; ATargetPosition: TVector3D);
  end;

  // Inimigo UFO
  TEnemy = class(TGameObject)
  private
    FLastShot: Cardinal;
    FShotCooldown: Cardinal;
    FDirection: Single;
    FMoveTimer: Single;
  public
    constructor Create(APosition: TVector3D);
    procedure Update(DeltaTime: Single); override;
    function CanShoot: Boolean;
    procedure Shoot;
  end;

  // Avião
  TAirplane = class(TGameObject)
  private
    FDirection: Single;
  public
    constructor Create(APosition: TVector3D);
    procedure Update(DeltaTime: Single); override;
  end;

  // Paraquedista
  TParachutist = class(TGameObject)
  private
    FParachuteOpen: Boolean;
  public
    constructor Create(APosition: TVector3D);
    procedure Update(DeltaTime: Single); override;
    
    property ParachuteOpen: Boolean read FParachuteOpen;
  end;

  // Explosão
  TExplosion = class(TGameObject)
  private
    FLifeTime: Single;
    FMaxLifeTime: Single;
    FParticles: Integer;
  public
    constructor Create(APosition: TVector3D);
    procedure Update(DeltaTime: Single); override;
    function IsFinished: Boolean;
    
    property LifeTime: Single read FLifeTime;
    property MaxLifeTime: Single read FMaxLifeTime;
  end;

  // Estrela (campo de estrelas)
  TStar = class(TGameObject)
  public
    constructor Create(APosition: TVector3D);
    procedure Update(DeltaTime: Single); override;
  end;

  // Listas de objetos
  TGameObjectList<T: TGameObject> = class(TObjectList<T>)
  public
    procedure UpdateAll(DeltaTime: Single);
    procedure RemoveInactive;
  end;

implementation

{ TVector3D }

constructor TVector3D.Create(AX, AY, AZ: Single);
begin
  X := AX;
  Y := AY;
  Z := AZ;
end;

function TVector3D.Add(const Other: TVector3D): TVector3D;
begin
  Result := TVector3D.Create(X + Other.X, Y + Other.Y, Z + Other.Z);
end;

function TVector3D.Subtract(const Other: TVector3D): TVector3D;
begin
  Result := TVector3D.Create(X - Other.X, Y - Other.Y, Z - Other.Z);
end;

function TVector3D.Multiply(Factor: Single): TVector3D;
begin
  Result := TVector3D.Create(X * Factor, Y * Factor, Z * Factor);
end;

function TVector3D.Distance(const Other: TVector3D): Single;
begin
  Result := Sqrt(Sqr(X - Other.X) + Sqr(Y - Other.Y) + Sqr(Z - Other.Z));
end;

{ TGameObject }

constructor TGameObject.Create(APosition: TVector3D; ASize: Single; AColor: TColor);
begin
  inherited Create;
  FPosition := APosition;
  FSize := ASize;
  FColor := AColor;
  FActive := True;
  FVelocity := TVector3D.Create(0, 0, 0);
end;

procedure TGameObject.Update(DeltaTime: Single);
begin
  Move(DeltaTime);
end;

procedure TGameObject.Move(DeltaTime: Single);
begin
  FPosition := FPosition.Add(FVelocity.Multiply(DeltaTime));
end;

function TGameObject.CheckCollision(Other: TGameObject): Boolean;
var
  Distance: Single;
begin
  Distance := FPosition.Distance(Other.Position);
  Result := Distance < (FSize + Other.Size) / 2;
end;

{ TPlayer }

constructor TPlayer.Create(APosition: TVector3D);
begin
  inherited Create(APosition, 1.0, clLime);
  FHits := 0;
  FColorIndex := 0;
  FColors[0] := clLime;    // Verde
  FColors[1] := clBlue;    // Azul
  FColors[2] := clRed;     // Vermelho
  FShotCooldown := 200;    // 200ms entre tiros
  FLastShot := 0;
end;

procedure TPlayer.Update(DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  
  // Limitar movimento nas bordas
  if FPosition.X < -10 then
    FPosition.X := -10;
  if FPosition.X > 10 then
    FPosition.X := 10;
end;

procedure TPlayer.Hit;
begin
  Inc(FHits);
  UpdateColor;
end;

function TPlayer.CanShoot: Boolean;
begin
  Result := GetTickCount - FLastShot > FShotCooldown;
end;

procedure TPlayer.Shoot;
begin
  if CanShoot then
    FLastShot := GetTickCount;
end;

procedure TPlayer.UpdateColor;
begin
  FColorIndex := FHits mod 3;
  FColor := FColors[FColorIndex];
end;

{ TBullet }

constructor TBullet.Create(APosition: TVector3D; AIsPlayerBullet: Boolean);
var
  PlayerPos: TVector3D;
  Direction: TVector3D;
  Speed: Single;
begin
  inherited Create(APosition, AIsPlayerBullet);
  
  if AIsPlayerBullet then
    FVelocity := TVector3D.Create(0, 10, 0)  // Para cima (vertical)
  else
  begin
    // Posição do jogador (assumindo que está em 0, -5, -5)
    PlayerPos := TVector3D.Create(0, -5, -5);
    
    // Calcular direção normalizada para o jogador
    Direction := PlayerPos.Subtract(APosition);
    
    // Normalizar a direção (fazer com que tenha magnitude 1)
    Speed := 8.0; // Velocidade dos projéteis inimigos
    if Direction.Distance(TVector3D.Create(0, 0, 0)) > 0.1 then
    begin
      FVelocity := TVector3D.Create(
        (Direction.X / Direction.Distance(TVector3D.Create(0, 0, 0))) * Speed,
        (Direction.Y / Direction.Distance(TVector3D.Create(0, 0, 0))) * Speed,
        (Direction.Z / Direction.Distance(TVector3D.Create(0, 0, 0))) * Speed
      );
    end
    else
    begin
      // Fallback se a direção for zero
      FVelocity := TVector3D.Create(0, 0, Speed);
    end;
  end;
end;

procedure TBullet.Update(DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  
  // Desativar se sair da tela
  if (FPosition.Z < -20) or (FPosition.Z > 20) then
    FActive := False;
end;

{ TEnemy }

constructor TEnemy.Create(APosition: TVector3D);
begin
  inherited Create(APosition, 1.5, clFuchsia);
  FShotCooldown := 2000 + Random(3000); // 2-5 segundos
  FLastShot := GetTickCount;
  FDirection := 1;
  FMoveTimer := 0;
  FVelocity := TVector3D.Create(2, 0, 0);
end;

procedure TEnemy.Update(DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  
  FMoveTimer := FMoveTimer + DeltaTime;
  
  // Movimento lateral com mudança de direção
  if (FPosition.X > 8) or (FPosition.X < -8) then
  begin
    FDirection := -FDirection;
    FVelocity.X := FDirection * 2;
    FPosition.Z := FPosition.Z + 1; // Avançar para frente
  end;
  
  // Desativar se muito próximo do jogador
  if FPosition.Z > 15 then
    FActive := False;
end;

function TEnemy.CanShoot: Boolean;
begin
  Result := GetTickCount - FLastShot > FShotCooldown;
end;

procedure TEnemy.Shoot;
begin
  if CanShoot then
  begin
    FLastShot := GetTickCount;
    FShotCooldown := 2000 + Random(3000); // Novo intervalo aleatório
  end;
end;

{ TAirplane }

constructor TAirplane.Create(APosition: TVector3D);
begin
  inherited Create(APosition, 2.0, clSilver);
  FDirection := 1;
  if Random(2) = 0 then
    FDirection := -1;
  FVelocity := TVector3D.Create(FDirection * 8, 0, 0);
end;

procedure TAirplane.Update(DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  
  // Desativar se sair da tela
  if (FPosition.X > 15) or (FPosition.X < -15) then
    FActive := False;
end;

{ TParachutist }

constructor TParachutist.Create(APosition: TVector3D);
begin
  inherited Create(APosition, 0.5, clWhite);
  FParachuteOpen := False;
  FVelocity := TVector3D.Create(0, 0, 3); // Caindo devagar
end;

procedure TParachutist.Update(DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  
  // Abrir paraquedas após cair um pouco
  if FPosition.Z > 5 then
  begin
    FParachuteOpen := True;
    FVelocity.Z := 1; // Cair mais devagar
  end;
  
  // Desativar se chegar ao chão
  if FPosition.Z > 15 then
    FActive := False;
end;

{ TExplosion }

constructor TExplosion.Create(APosition: TVector3D);
begin
  inherited Create(APosition, 2.0, $0080FF); // Cor laranja em RGB
  FLifeTime := 0;
  FMaxLifeTime := 1.0; // 1 segundo
  FParticles := 10;
end;

procedure TExplosion.Update(DeltaTime: Single);
begin
  FLifeTime := FLifeTime + DeltaTime;
  
  // Expandir explosão
  FSize := 2.0 + (FLifeTime / FMaxLifeTime) * 3.0;
  
  if IsFinished then
    FActive := False;
end;

function TExplosion.IsFinished: Boolean;
begin
  Result := FLifeTime >= FMaxLifeTime;
end;

{ TStar }

constructor TStar.Create(APosition: TVector3D);
begin
  inherited Create(APosition, 0.1, clWhite);
  FVelocity := TVector3D.Create(0, 0, 0); // Estrelas estáticas
end;

procedure TStar.Update(DeltaTime: Single);
begin
  // Estrelas ficam estáticas - não chamamos inherited Update
  // e não reposicionamos as estrelas
end;

{ TBulletWithTarget }

constructor TBulletWithTarget.Create(APosition: TVector3D; AIsPlayerBullet: Boolean; ATargetPosition: TVector3D);
var
  Direction: TVector3D;
  Speed: Single;
  Distance: Single;
begin
  if AIsPlayerBullet then
    inherited Create(APosition, 0.2, clYellow)
  else
    inherited Create(APosition, 0.2, clRed);
    
  FIsPlayerBullet := AIsPlayerBullet;
  
  if AIsPlayerBullet then
    FVelocity := TVector3D.Create(0, 10, 0)  // Para cima (vertical)
  else
  begin
    // Calcular direção normalizada para o alvo
    Direction := ATargetPosition.Subtract(APosition);
    Distance := Sqrt(Sqr(Direction.X) + Sqr(Direction.Y) + Sqr(Direction.Z));
    
    // Normalizar a direção e aplicar velocidade
    Speed := 8.0; // Velocidade dos projéteis inimigos
    if Distance > 0.1 then
    begin
      FVelocity := TVector3D.Create(
        (Direction.X / Distance) * Speed,
        (Direction.Y / Distance) * Speed,
        (Direction.Z / Distance) * Speed
      );
    end
    else
    begin
      // Fallback se a direção for zero
      FVelocity := TVector3D.Create(0, 0, Speed);
    end;
  end;
end;

{ TGameObjectList<T> }

procedure TGameObjectList<T>.UpdateAll(DeltaTime: Single);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Update(DeltaTime);
end;

procedure TGameObjectList<T>.RemoveInactive;
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
  begin
    if not Items[i].Active then
      Delete(i);
  end;
end;

end.