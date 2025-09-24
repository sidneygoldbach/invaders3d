unit GameEngine;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math,
  Vcl.Graphics, System.Generics.Collections, Winapi.Windows, GameObjects, Renderer3D, AudioSystem;

type
  // Eventos do jogo
  TGameEvent = procedure of object;
  
  TGameEngine = class
  private
    // Sistemas
    FRenderer: TRenderer3D;
    FAudioSystem: TAudioSystem;
    
    // Objetos do jogo
    FPlayer: TPlayer;
    FEnemies: TGameObjectList<TEnemy>;
    FBullets: TGameObjectList<TBullet>;
    FEnemyBullets: TGameObjectList<TBullet>;
    FAirplanes: TGameObjectList<TAirplane>;
    FParachutists: TGameObjectList<TParachutist>;
    FExplosions: TGameObjectList<TExplosion>;
    FStars: TGameObjectList<TStar>;
    
    // Estado do jogo
    FScore: Integer;
    FLives: Integer;
    FGameRunning: Boolean;
    FKeys: TGameKeys;
    FLastUpdate: Cardinal;
    
    // Timers para spawn
    FLastEnemySpawn: Cardinal;
    FLastAirplaneSpawn: Cardinal;
    FEnemySpawnInterval: Cardinal;
    FAirplaneSpawnInterval: Cardinal;
    
    // Eventos
    FOnScoreChange: TGameEvent;
    FOnLivesChange: TGameEvent;
    FOnGameOver: TGameEvent;
    
    // Métodos privados
    procedure InitializeStarField;
    procedure SpawnEnemy;
    procedure SpawnAirplane;
    procedure SpawnParachutist(Position: TVector3D);
    procedure CheckCollisions;
    procedure UpdateGameObjects(DeltaTime: Single);
    procedure HandleInput(DeltaTime: Single);
    procedure CleanupObjects;
    
  public
    constructor Create(ARenderer: TRenderer3D; AAudioSystem: TAudioSystem);
    destructor Destroy; override;
    
    // Controle do jogo
    procedure StartGame;
    procedure RestartGame;
    procedure Update;
    procedure Render;
    procedure UpdateKeys(const Keys: TGameKeys);
    
    // Propriedades
    property Score: Integer read FScore;
    property Lives: Integer read FLives;
    property GameRunning: Boolean read FGameRunning;
    
    // Eventos
    property OnScoreChange: TGameEvent read FOnScoreChange write FOnScoreChange;
    property OnLivesChange: TGameEvent read FOnLivesChange write FOnLivesChange;
    property OnGameOver: TGameEvent read FOnGameOver write FOnGameOver;
  end;

implementation

{ TGameEngine }

constructor TGameEngine.Create(ARenderer: TRenderer3D; AAudioSystem: TAudioSystem);
begin
  inherited Create;
  
  FRenderer := ARenderer;
  FAudioSystem := AAudioSystem;
  
  // Criar listas de objetos
  FEnemies := TGameObjectList<TEnemy>.Create(True);
  FBullets := TGameObjectList<TBullet>.Create(True);
  FEnemyBullets := TGameObjectList<TBullet>.Create(True);
  FAirplanes := TGameObjectList<TAirplane>.Create(True);
  FParachutists := TGameObjectList<TParachutist>.Create(True);
  FExplosions := TGameObjectList<TExplosion>.Create(True);
  FStars := TGameObjectList<TStar>.Create(True);
  
  // Inicializar estado do jogo
  FScore := 0;
  FLives := 3;
  FGameRunning := False;
  FillChar(FKeys, SizeOf(FKeys), 0);
  
  // Configurar timers
  FEnemySpawnInterval := 3000; // 3 segundos
  FAirplaneSpawnInterval := 15000; // 15 segundos
  FLastEnemySpawn := 0;
  FLastAirplaneSpawn := 0;
  FLastUpdate := GetTickCount;
  
  // Criar jogador
  FPlayer := TPlayer.Create(TVector3D.Create(0, -2, -5));
  
  // Inicializar campo de estrelas
  InitializeStarField;
end;

destructor TGameEngine.Destroy;
begin
  FPlayer.Free;
  FEnemies.Free;
  FBullets.Free;
  FEnemyBullets.Free;
  FAirplanes.Free;
  FParachutists.Free;
  FExplosions.Free;
  FStars.Free;
  
  inherited Destroy;
end;

procedure TGameEngine.InitializeStarField;
var
  I: Integer;
  Star: TStar;
  Position: TVector3D;
begin
  for I := 0 to 199 do // 200 estrelas como no JavaScript
  begin
    Position := TVector3D.Create(
      (Random - 0.5) * 100,  // X: -50 a 50 (área maior)
      (Random - 0.5) * 50,   // Y: -25 a 25 (área maior)
      (Random - 0.5) * 50    // Z: -25 a 25 (área maior)
    );
    Star := TStar.Create(Position);
    FStars.Add(Star);
  end;
end;

procedure TGameEngine.StartGame;
begin
  FGameRunning := True;
  FLastUpdate := GetTickCount;
  
  if Assigned(FAudioSystem) then
    FAudioSystem.StartBackgroundMusic;
end;

procedure TGameEngine.RestartGame;
begin
  // Limpar objetos
  FEnemies.Clear;
  FBullets.Clear;
  FEnemyBullets.Clear;
  FAirplanes.Clear;
  FParachutists.Clear;
  FExplosions.Clear;
  
  // Resetar estado
  FScore := 0;
  FLives := 3;
  FGameRunning := True;
  
  // Resetar jogador
  FPlayer.Position := TVector3D.Create(0, 0, 10);
  FPlayer.Velocity := TVector3D.Create(0, 0, 0);
  
  // Resetar timers
  FLastEnemySpawn := 0;
  FLastAirplaneSpawn := 0;
  FLastUpdate := GetTickCount;
  
  if Assigned(FAudioSystem) then
    FAudioSystem.StartBackgroundMusic;
end;

procedure TGameEngine.Update;
var
  CurrentTime: Cardinal;
  DeltaTime: Single;
begin
  if not FGameRunning then Exit;
  
  CurrentTime := GetTickCount;
  DeltaTime := (CurrentTime - FLastUpdate) / 1000.0; // Converter para segundos
  FLastUpdate := CurrentTime;
  
  // Limitar delta time para evitar saltos grandes
  if DeltaTime > 0.1 then
    DeltaTime := 0.1;
  
  HandleInput(DeltaTime);
  UpdateGameObjects(DeltaTime);
  CheckCollisions;
  CleanupObjects;
  
  // Spawn de inimigos
  if CurrentTime - FLastEnemySpawn > FEnemySpawnInterval then
  begin
    SpawnEnemy;
    FLastEnemySpawn := CurrentTime;
  end;
  
  // Spawn de aviões
  if CurrentTime - FLastAirplaneSpawn > FAirplaneSpawnInterval then
  begin
    SpawnAirplane;
    FLastAirplaneSpawn := CurrentTime;
  end;
  
  // Verificar game over
  if FLives <= 0 then
  begin
    FGameRunning := False;
    if Assigned(FOnGameOver) then
      FOnGameOver;
  end;
end;

procedure TGameEngine.HandleInput(DeltaTime: Single);
var
  MoveSpeed: Single;
  Bullet: TBullet;
begin
  MoveSpeed := 10.0; // Unidades por segundo
  
  // Movimento do jogador
  var PlayerVelocity: TVector3D;
  PlayerVelocity := TVector3D.Create(0, 0, 0);
  
  if FKeys.Left then
    PlayerVelocity.X := -MoveSpeed;
  if FKeys.Right then
    PlayerVelocity.X := MoveSpeed;
    
  FPlayer.Velocity := PlayerVelocity;
  
  // Tiro do jogador
  if FKeys.Space and FPlayer.CanShoot then
  begin
    FPlayer.Shoot;
    Bullet := TBullet.Create(FPlayer.Position, True);
    FBullets.Add(Bullet);
    
    if Assigned(FAudioSystem) then
      FAudioSystem.PlayPlayerShoot;
  end;
end;

procedure TGameEngine.UpdateGameObjects(DeltaTime: Single);
var
  i: Integer;
  Enemy: TEnemy;
  Bullet: TBullet;
begin
  // Atualizar jogador
  FPlayer.Update(DeltaTime);
  
  // Atualizar e fazer inimigos atirarem
  for i := 0 to FEnemies.Count - 1 do
  begin
    Enemy := FEnemies[i];
    Enemy.Update(DeltaTime);
    
    if Enemy.CanShoot and (Random < 0.01) then // 1% de chance por frame
    begin
      Enemy.Shoot;
      Bullet := TBullet.Create(Enemy.Position, False);
      FEnemyBullets.Add(Bullet);
      
      if Assigned(FAudioSystem) then
        FAudioSystem.PlayEnemyShoot;
    end;
  end;
  
  // Atualizar todos os objetos
  FBullets.UpdateAll(DeltaTime);
  FEnemyBullets.UpdateAll(DeltaTime);
  FAirplanes.UpdateAll(DeltaTime);
  FParachutists.UpdateAll(DeltaTime);
  FExplosions.UpdateAll(DeltaTime);
  FStars.UpdateAll(DeltaTime);
end;

procedure TGameEngine.CheckCollisions;
var
  i, j: Integer;
  Bullet: TBullet;
  Enemy: TEnemy;
  Airplane: TAirplane;
  Explosion: TExplosion;
begin
  // Colisões: Projéteis do jogador vs Inimigos
  for i := FBullets.Count - 1 downto 0 do
  begin
    Bullet := FBullets[i];
    
    for j := FEnemies.Count - 1 downto 0 do
    begin
      Enemy := FEnemies[j];
      
      if Bullet.CheckCollision(Enemy) then
      begin
        // Criar explosão
        Explosion := TExplosion.Create(Enemy.Position);
        FExplosions.Add(Explosion);
        
        // Aumentar pontuação
        Inc(FScore, 100);
        if Assigned(FOnScoreChange) then
          FOnScoreChange;
        
        // Tocar som
        if Assigned(FAudioSystem) then
          FAudioSystem.PlayEnemyHit;
        
        // Remover objetos
        FBullets.Delete(i);
        FEnemies.Delete(j);
        Break;
      end;
    end;
  end;
  
  // Colisões: Projéteis do jogador vs Aviões
  for i := FBullets.Count - 1 downto 0 do
  begin
    if i >= FBullets.Count then Continue;
    Bullet := FBullets[i];
    
    for j := FAirplanes.Count - 1 downto 0 do
    begin
      Airplane := FAirplanes[j];
      
      if Bullet.CheckCollision(Airplane) then
      begin
        // Criar explosão
        Explosion := TExplosion.Create(Airplane.Position);
        FExplosions.Add(Explosion);
        
        // Spawn paraquedistas
        SpawnParachutist(Airplane.Position);
        
        // Aumentar pontuação
        Inc(FScore, 200);
        if Assigned(FOnScoreChange) then
          FOnScoreChange;
        
        // Tocar som
        if Assigned(FAudioSystem) then
          FAudioSystem.PlayEnemyHit;
        
        // Remover objetos
        FBullets.Delete(i);
        FAirplanes.Delete(j);
        Break;
      end;
    end;
  end;
  
  // Colisões: Projéteis inimigos vs Jogador
  for i := FEnemyBullets.Count - 1 downto 0 do
  begin
    Bullet := FEnemyBullets[i];
    
    if Bullet.CheckCollision(FPlayer) then
    begin
      // Jogador atingido
      FPlayer.Hit;
      
      // Verificar se perdeu uma vida
      if FPlayer.Hits mod 3 = 0 then
      begin
        Dec(FLives);
        if Assigned(FOnLivesChange) then
          FOnLivesChange;
      end;
      
      // Tocar som
      if Assigned(FAudioSystem) then
        FAudioSystem.PlayPlayerHit;
      
      // Remover projétil
      FEnemyBullets.Delete(i);
    end;
  end;
  
  // Colisões: Paraquedistas vs Jogador
  for i := FParachutists.Count - 1 downto 0 do
  begin
    if FParachutists[i].CheckCollision(FPlayer) then
    begin
      // Aumentar pontuação por salvar paraquedista
      Inc(FScore, 50);
      if Assigned(FOnScoreChange) then
        FOnScoreChange;
      
      // Remover paraquedista
      FParachutists.Delete(i);
    end;
  end;
end;

procedure TGameEngine.CleanupObjects;
begin
  FEnemies.RemoveInactive;
  FBullets.RemoveInactive;
  FEnemyBullets.RemoveInactive;
  FAirplanes.RemoveInactive;
  FParachutists.RemoveInactive;
  FExplosions.RemoveInactive;
end;

procedure TGameEngine.SpawnEnemy;
var
  Enemy: TEnemy;
  X, Y, Z: Single;
begin
  // Posições aleatórias na frente da câmera
  X := Random * 16 - 8;  // -8 a 8
  Y := Random * 6 - 3;   // -3 a 3
  Z := Random * 10 - 20; // -20 a -10 (na frente da câmera)
  
  Enemy := TEnemy.Create(TVector3D.Create(X, Y, Z));
  FEnemies.Add(Enemy);
end;

procedure TGameEngine.SpawnAirplane;
var
  Airplane: TAirplane;
  Position: TVector3D;
begin
  Position := TVector3D.Create(
    -15,               // X: Começar fora da tela
    5 + Random * 3,    // Y: 5 a 8
    -10 + Random * 5   // Z: -10 a -5
  );
  
  Airplane := TAirplane.Create(Position);
  FAirplanes.Add(Airplane);
end;

procedure TGameEngine.SpawnParachutist(Position: TVector3D);
var
  i: Integer;
  Parachutist: TParachutist;
  ParachutistPos: TVector3D;
begin
  // Spawn 2-4 paraquedistas
  for i := 0 to 1 + Random(3) do
  begin
    ParachutistPos := TVector3D.Create(
      Position.X + (-1 + Random * 2),
      Position.Y,
      Position.Z
    );
    
    Parachutist := TParachutist.Create(ParachutistPos);
    FParachutists.Add(Parachutist);
  end;
end;

procedure TGameEngine.Render;
var
  i: Integer;
begin
  if not Assigned(FRenderer) then Exit;
  
  // Renderizar campo de estrelas
  FRenderer.RenderStars(FStars);
  
  // Renderizar jogador
  if FPlayer.Active then
    FRenderer.RenderPlayer(FPlayer);
  
  // Renderizar inimigos
  for i := 0 to FEnemies.Count - 1 do
    FRenderer.RenderEnemy(FEnemies[i]);
  
  // Renderizar projéteis
  for i := 0 to FBullets.Count - 1 do
    FRenderer.RenderBullet(FBullets[i]);
  
  for i := 0 to FEnemyBullets.Count - 1 do
    FRenderer.RenderBullet(FEnemyBullets[i]);
  
  // Renderizar aviões
  for i := 0 to FAirplanes.Count - 1 do
    FRenderer.RenderAirplane(FAirplanes[i]);
  
  // Renderizar paraquedistas
  for i := 0 to FParachutists.Count - 1 do
    FRenderer.RenderParachutist(FParachutists[i]);
  
  // Renderizar explosões
  for i := 0 to FExplosions.Count - 1 do
    FRenderer.RenderExplosion(FExplosions[i]);
  
  // Renderizar UI
  FRenderer.RenderUI(FScore, FLives);
end;

procedure TGameEngine.UpdateKeys(const Keys: TGameKeys);
begin
  FKeys := Keys;
end;

end.