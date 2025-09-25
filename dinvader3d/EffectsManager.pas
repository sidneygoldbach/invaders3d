unit EffectsManager;

interface

uses
  Winapi.Windows, Vcl.Graphics, System.Classes, System.SysUtils, System.Math;

type
  // Tipos de efeitos especiais
  TEffectType = (etParticleTrail, etEnergyField, etShockwave, etGlow, etSpark);
  
  // Partícula individual
  TParticle = record
    X, Y, Z: Single;
    VelX, VelY, VelZ: Single;
    Life: Single;
    MaxLife: Single;
    Size: Single;
    Color: TColor;
    Alpha: Byte;
  end;
  
  // Sistema de partículas
  TParticleSystem = class
  private
    FParticles: array of TParticle;
    FMaxParticles: Integer;
    FActiveParticles: Integer;
    FCanvas: TCanvas;
    
    procedure UpdateParticle(var Particle: TParticle; DeltaTime: Single);
    procedure RenderParticle(const Particle: TParticle);
    
  public
    constructor Create(ACanvas: TCanvas; MaxParticles: Integer = 100);
    destructor Destroy; override;
    
    procedure AddParticle(X, Y, Z: Single; VelX, VelY, VelZ: Single; 
                         Life: Single; Size: Single; Color: TColor);
    procedure Update(DeltaTime: Single);
    procedure Render;
    procedure Clear;
    
    property ActiveParticles: Integer read FActiveParticles;
  end;
  
  // Gerenciador de efeitos especiais
  TEffectsManager = class
  private
    FCanvas: TCanvas;
    FParticleSystem: TParticleSystem;
    FWidth, FHeight: Integer;
    
    procedure CreateExplosionEffect(X, Y, Z: Single; Intensity: Single);
    procedure CreateTrailEffect(X, Y, Z: Single; VelX, VelY, VelZ: Single);
    procedure CreateEnergyEffect(X, Y, Z: Single);
    
  public
    constructor Create(ACanvas: TCanvas; Width, Height: Integer);
    destructor Destroy; override;
    
    procedure Update(DeltaTime: Single);
    procedure Render;
    
    // Efeitos específicos
    procedure AddExplosion(X, Y, Z: Single; Intensity: Single = 1.0);
    procedure AddLaserTrail(X, Y, Z: Single; VelX, VelY, VelZ: Single);
    procedure AddEnergyField(X, Y, Z: Single);
    procedure AddShockwave(X, Y, Z: Single; Radius: Single);
    procedure AddGlow(X, Y, Z: Single; Color: TColor; Intensity: Single);
    
    // Efeitos ambientais
    procedure AddStarTwinkle(X, Y, Z: Single);
    procedure AddEngineFlame(X, Y, Z: Single; VelX, VelY, VelZ: Single);
    
    procedure Clear;
  end;

implementation

{ TParticleSystem }

constructor TParticleSystem.Create(ACanvas: TCanvas; MaxParticles: Integer);
begin
  inherited Create;
  FCanvas := ACanvas;
  FMaxParticles := MaxParticles;
  SetLength(FParticles, FMaxParticles);
  FActiveParticles := 0;
end;

destructor TParticleSystem.Destroy;
begin
  SetLength(FParticles, 0);
  inherited Destroy;
end;

procedure TParticleSystem.AddParticle(X, Y, Z: Single; VelX, VelY, VelZ: Single; 
                                     Life: Single; Size: Single; Color: TColor);
var
  i: Integer;
begin
  // Encontrar slot livre
  for i := 0 to FMaxParticles - 1 do
  begin
    if FParticles[i].Life <= 0 then
    begin
      FParticles[i].X := X;
      FParticles[i].Y := Y;
      FParticles[i].Z := Z;
      FParticles[i].VelX := VelX;
      FParticles[i].VelY := VelY;
      FParticles[i].VelZ := VelZ;
      FParticles[i].Life := Life;
      FParticles[i].MaxLife := Life;
      FParticles[i].Size := Size;
      FParticles[i].Color := Color;
      FParticles[i].Alpha := 255;
      
      if i >= FActiveParticles then
        FActiveParticles := i + 1;
      Break;
    end;
  end;
end;

procedure TParticleSystem.UpdateParticle(var Particle: TParticle; DeltaTime: Single);
begin
  if Particle.Life <= 0 then Exit;
  
  // Atualizar posição
  Particle.X := Particle.X + Particle.VelX * DeltaTime;
  Particle.Y := Particle.Y + Particle.VelY * DeltaTime;
  Particle.Z := Particle.Z + Particle.VelZ * DeltaTime;
  
  // Atualizar vida
  Particle.Life := Particle.Life - DeltaTime;
  
  // Atualizar alpha baseado na vida
  if Particle.MaxLife > 0 then
    Particle.Alpha := Round(255 * (Particle.Life / Particle.MaxLife))
  else
    Particle.Alpha := 0;
    
  // Aplicar gravidade leve
  Particle.VelY := Particle.VelY + 0.1 * DeltaTime;
  
  // Aplicar resistência do ar
  Particle.VelX := Particle.VelX * 0.99;
  Particle.VelY := Particle.VelY * 0.99;
  Particle.VelZ := Particle.VelZ * 0.99;
end;

procedure TParticleSystem.RenderParticle(const Particle: TParticle);
var
  ScreenX, ScreenY: Integer;
  Size: Integer;
  R, G, B: Byte;
begin
  if Particle.Life <= 0 then Exit;
  
  // Projeção 3D simples
  ScreenX := Round(Particle.X + (Particle.Z * 0.1));
  ScreenY := Round(Particle.Y + (Particle.Z * 0.1));
  
  Size := Max(1, Round(Particle.Size * (1.0 + Particle.Z / 100.0)));
  
  // Extrair componentes RGB
  R := GetRValue(Particle.Color);
  G := GetGValue(Particle.Color);
  B := GetBValue(Particle.Color);
  
  // Aplicar alpha
  R := Round(R * Particle.Alpha / 255);
  G := Round(G * Particle.Alpha / 255);
  B := Round(B * Particle.Alpha / 255);
  
  FCanvas.Pen.Color := RGB(R, G, B);
  FCanvas.Brush.Color := RGB(R, G, B);
  FCanvas.Brush.Style := bsSolid;
  
  FCanvas.Ellipse(ScreenX - Size, ScreenY - Size,
                  ScreenX + Size, ScreenY + Size);
end;

procedure TParticleSystem.Update(DeltaTime: Single);
var
  i: Integer;
begin
  for i := 0 to FActiveParticles - 1 do
    UpdateParticle(FParticles[i], DeltaTime);
end;

procedure TParticleSystem.Render;
var
  i: Integer;
begin
  for i := 0 to FActiveParticles - 1 do
    RenderParticle(FParticles[i]);
end;

procedure TParticleSystem.Clear;
var
  i: Integer;
begin
  for i := 0 to FMaxParticles - 1 do
    FParticles[i].Life := 0;
  FActiveParticles := 0;
end;

{ TEffectsManager }

constructor TEffectsManager.Create(ACanvas: TCanvas; Width, Height: Integer);
begin
  inherited Create;
  FCanvas := ACanvas;
  FWidth := Width;
  FHeight := Height;
  FParticleSystem := TParticleSystem.Create(ACanvas, 200);
end;

destructor TEffectsManager.Destroy;
begin
  FParticleSystem.Free;
  inherited Destroy;
end;

procedure TEffectsManager.Update(DeltaTime: Single);
begin
  FParticleSystem.Update(DeltaTime);
end;

procedure TEffectsManager.Render;
begin
  FParticleSystem.Render;
end;

procedure TEffectsManager.CreateExplosionEffect(X, Y, Z: Single; Intensity: Single);
var
  i: Integer;
  Angle, Speed: Single;
  VelX, VelY, VelZ: Single;
  ParticleCount: Integer;
begin
  ParticleCount := Round(20 * Intensity);
  
  for i := 0 to ParticleCount - 1 do
  begin
    Angle := (2 * Pi * i) / ParticleCount + Random * 0.5;
    Speed := (50 + Random * 100) * Intensity;
    
    VelX := Cos(Angle) * Speed;
    VelY := Sin(Angle) * Speed;
    VelZ := (Random - 0.5) * Speed * 0.5;
    
    FParticleSystem.AddParticle(
      X + (Random - 0.5) * 10,
      Y + (Random - 0.5) * 10,
      Z + (Random - 0.5) * 10,
      VelX, VelY, VelZ,
      1.0 + Random * 2.0,
      2 + Random * 4,
      RGB(255, 100 + Random(155), Random(100))
    );
  end;
end;

procedure TEffectsManager.CreateTrailEffect(X, Y, Z: Single; VelX, VelY, VelZ: Single);
var
  i: Integer;
  TrailX, TrailY, TrailZ: Single;
begin
  for i := 0 to 4 do
  begin
    TrailX := X - VelX * i * 0.1;
    TrailY := Y - VelY * i * 0.1;
    TrailZ := Z - VelZ * i * 0.1;
    
    FParticleSystem.AddParticle(
      TrailX + (Random - 0.5) * 5,
      TrailY + (Random - 0.5) * 5,
      TrailZ + (Random - 0.5) * 5,
      (Random - 0.5) * 20,
      (Random - 0.5) * 20,
      (Random - 0.5) * 20,
      0.5 + Random * 0.5,
      1 + Random * 2,
      RGB(0, 150 + Random(105), 255)
    );
  end;
end;

procedure TEffectsManager.CreateEnergyEffect(X, Y, Z: Single);
var
  i: Integer;
  Angle: Single;
  Radius: Single;
begin
  for i := 0 to 7 do
  begin
    Angle := (2 * Pi * i) / 8;
    Radius := 15 + Random * 10;
    
    FParticleSystem.AddParticle(
      X + Cos(Angle) * Radius,
      Y + Sin(Angle) * Radius,
      Z,
      Cos(Angle) * 30,
      Sin(Angle) * 30,
      (Random - 0.5) * 20,
      1.5 + Random * 1.0,
      1 + Random * 3,
      RGB(255, 255, 100 + Random(155))
    );
  end;
end;

procedure TEffectsManager.AddExplosion(X, Y, Z: Single; Intensity: Single);
begin
  CreateExplosionEffect(X, Y, Z, Intensity);
end;

procedure TEffectsManager.AddLaserTrail(X, Y, Z: Single; VelX, VelY, VelZ: Single);
begin
  CreateTrailEffect(X, Y, Z, VelX, VelY, VelZ);
end;

procedure TEffectsManager.AddEnergyField(X, Y, Z: Single);
begin
  CreateEnergyEffect(X, Y, Z);
end;

procedure TEffectsManager.AddShockwave(X, Y, Z: Single; Radius: Single);
var
  i: Integer;
  Angle: Single;
  Speed: Single;
begin
  for i := 0 to 15 do
  begin
    Angle := (2 * Pi * i) / 16;
    Speed := Radius * 2;
    
    FParticleSystem.AddParticle(
      X, Y, Z,
      Cos(Angle) * Speed,
      Sin(Angle) * Speed,
      0,
      2.0,
      3 + Random * 2,
      RGB(255, 255, 255)
    );
  end;
end;

procedure TEffectsManager.AddGlow(X, Y, Z: Single; Color: TColor; Intensity: Single);
var
  i: Integer;
begin
  for i := 0 to Round(5 * Intensity) do
  begin
    FParticleSystem.AddParticle(
      X + (Random - 0.5) * 20,
      Y + (Random - 0.5) * 20,
      Z + (Random - 0.5) * 10,
      (Random - 0.5) * 10,
      (Random - 0.5) * 10,
      (Random - 0.5) * 5,
      1.0 + Random * 1.5,
      2 + Random * 3,
      Color
    );
  end;
end;

procedure TEffectsManager.AddStarTwinkle(X, Y, Z: Single);
begin
  FParticleSystem.AddParticle(
    X, Y, Z,
    0, 0, 0,
    0.5 + Random * 1.0,
    1 + Random * 2,
    RGB(255, 255, 200 + Random(55))
  );
end;

procedure TEffectsManager.AddEngineFlame(X, Y, Z: Single; VelX, VelY, VelZ: Single);
var
  i: Integer;
begin
  for i := 0 to 2 do
  begin
    FParticleSystem.AddParticle(
      X - VelX * 0.2,
      Y - VelY * 0.2,
      Z - VelZ * 0.2,
      -VelX * 0.5 + (Random - 0.5) * 20,
      -VelY * 0.5 + (Random - 0.5) * 20,
      -VelZ * 0.5 + (Random - 0.5) * 10,
      0.3 + Random * 0.4,
      1 + Random * 2,
      RGB(255, 100 + Random(100), Random(50))
    );
  end;
end;

procedure TEffectsManager.Clear;
begin
  FParticleSystem.Clear;
end;

end.