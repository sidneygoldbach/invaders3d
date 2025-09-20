// Variáveis globais do jogo
let scene, camera, renderer, player;
let enemies = [];
let bullets = [];
let enemyBullets = [];
let airplanes = [];
let parachutists = [];
let explosions = [];
let stars = [];
let score = 0;
let lives = 3;
let playerHits = 0; // Contador de acertos no jogador
let playerColors = [0x00ff00, 0x0066cc, 0xff0000]; // Verde, Azul, Vermelho
let currentColorIndex = 0;
let gameRunning = true;

// Controles
let keys = {
    left: false,
    right: false,
    space: false
};

// Configurações do jogo
const GAME_WIDTH = 20;
const GAME_HEIGHT = 15;
const GAME_DEPTH = 30;

// Inicialização do jogo
function init() {
    // Criar cena
    scene = new THREE.Scene();
    scene.fog = new THREE.Fog(0x000428, 10, 50);
    
    // Criar câmera
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.set(0, 5, 15);
    camera.lookAt(0, 0, 0);
    
    // Criar renderizador
    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setClearColor(0x000428);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    document.getElementById('gameContainer').appendChild(renderer.domElement);
    
    // Adicionar luzes
    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
    scene.add(ambientLight);
    
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(0, 10, 5);
    directionalLight.castShadow = true;
    directionalLight.shadow.mapSize.width = 2048;
    directionalLight.shadow.mapSize.height = 2048;
    scene.add(directionalLight);
    
    // Criar campo de estrelas
    createStarField();
    
    // Criar jogador (bonequinho colorido)
    createPlayer();
    
    // Adicionar event listeners
    document.addEventListener('keydown', onKeyDown);
    document.addEventListener('keyup', onKeyUp);
    window.addEventListener('resize', onWindowResize);
    
    // Iniciar loop do jogo
    animate();
    
    // Spawnar inimigos periodicamente
    setInterval(spawnEnemy, 2000);
    setInterval(spawnAirplane, 8000);
}

// Criar jogador (bonequinho 3D colorido)
function createPlayer() {
    const group = new THREE.Group();
    
    // Corpo
    const bodyGeometry = new THREE.CylinderGeometry(0.3, 0.4, 1.2, 8);
    const bodyMaterial = new THREE.MeshLambertMaterial({ color: playerColors[currentColorIndex] });
    const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
    body.position.y = 0.6;
    body.castShadow = true;
    body.userData = { type: 'body' }; // Marcar para mudança de cor
    group.add(body);
    
    // Cabeça
    const headGeometry = new THREE.SphereGeometry(0.4, 8, 6);
    const headMaterial = new THREE.MeshLambertMaterial({ color: 0xffdd88 });
    const head = new THREE.Mesh(headGeometry, headMaterial);
    head.position.y = 1.6;
    head.castShadow = true;
    group.add(head);
    
    // Braços
    const armGeometry = new THREE.CylinderGeometry(0.1, 0.1, 0.8, 6);
    const armMaterial = new THREE.MeshLambertMaterial({ color: 0xffdd88 });
    
    const leftArm = new THREE.Mesh(armGeometry, armMaterial);
    leftArm.position.set(-0.6, 0.8, 0);
    leftArm.rotation.z = Math.PI / 6;
    leftArm.castShadow = true;
    group.add(leftArm);
    
    const rightArm = new THREE.Mesh(armGeometry, armMaterial);
    rightArm.position.set(0.6, 0.8, 0);
    rightArm.rotation.z = -Math.PI / 6;
    rightArm.castShadow = true;
    group.add(rightArm);
    
    // Pernas
    const legGeometry = new THREE.CylinderGeometry(0.12, 0.12, 0.8, 6);
    const legMaterial = new THREE.MeshLambertMaterial({ color: 0x0066cc });
    
    const leftLeg = new THREE.Mesh(legGeometry, legMaterial);
    leftLeg.position.set(-0.2, -0.4, 0);
    leftLeg.castShadow = true;
    group.add(leftLeg);
    
    const rightLeg = new THREE.Mesh(legGeometry, legMaterial);
    rightLeg.position.set(0.2, -0.4, 0);
    rightLeg.castShadow = true;
    group.add(rightLeg);
    
    group.position.set(0, 0, 8);
    scene.add(group);
    player = group;
}

// Criar disco voador inimigo
function createUFO() {
    const group = new THREE.Group();
    
    // Corpo principal do disco
    const bodyGeometry = new THREE.CylinderGeometry(1, 1.5, 0.3, 16);
    const bodyMaterial = new THREE.MeshLambertMaterial({ color: 0x888888 });
    const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
    body.castShadow = true;
    group.add(body);
    
    // Cúpula superior
    const domeGeometry = new THREE.SphereGeometry(0.8, 12, 6, 0, Math.PI * 2, 0, Math.PI / 2);
    const domeMaterial = new THREE.MeshLambertMaterial({ color: 0x00ffff, transparent: true, opacity: 0.7 });
    const dome = new THREE.Mesh(domeGeometry, domeMaterial);
    dome.position.y = 0.2;
    dome.castShadow = true;
    group.add(dome);
    
    // Luzes piscantes
    const lightGeometry = new THREE.SphereGeometry(0.1, 6, 4);
    const lightMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000 });
    
    for (let i = 0; i < 6; i++) {
        const light = new THREE.Mesh(lightGeometry, lightMaterial);
        const angle = (i / 6) * Math.PI * 2;
        light.position.set(Math.cos(angle) * 1.2, 0, Math.sin(angle) * 1.2);
        group.add(light);
    }
    
    return group;
}

// Criar avião
function createAirplane() {
    const group = new THREE.Group();
    
    // Fuselagem
    const bodyGeometry = new THREE.CylinderGeometry(0.2, 0.3, 2, 8);
    const bodyMaterial = new THREE.MeshLambertMaterial({ color: 0x666666 });
    const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
    body.rotation.z = Math.PI / 2;
    body.castShadow = true;
    group.add(body);
    
    // Asas
    const wingGeometry = new THREE.BoxGeometry(3, 0.1, 0.5);
    const wingMaterial = new THREE.MeshLambertMaterial({ color: 0x444444 });
    const wings = new THREE.Mesh(wingGeometry, wingMaterial);
    wings.castShadow = true;
    group.add(wings);
    
    // Hélice
    const propGeometry = new THREE.BoxGeometry(0.1, 1.5, 0.05);
    const propMaterial = new THREE.MeshLambertMaterial({ color: 0x333333 });
    const prop = new THREE.Mesh(propGeometry, propMaterial);
    prop.position.x = 1.2;
    group.add(prop);
    
    return group;
}

// Criar paraquedista
function createParachutist() {
    const group = new THREE.Group();
    
    // Paraquedas
    const chuteGeometry = new THREE.SphereGeometry(0.8, 8, 4, 0, Math.PI * 2, 0, Math.PI / 2);
    const chuteMaterial = new THREE.MeshLambertMaterial({ color: 0xff6600 });
    const chute = new THREE.Mesh(chuteGeometry, chuteMaterial);
    chute.position.y = 1;
    chute.castShadow = true;
    group.add(chute);
    
    // Bonequinho pequeno
    const personGeometry = new THREE.CylinderGeometry(0.1, 0.1, 0.4, 6);
    const personMaterial = new THREE.MeshLambertMaterial({ color: 0x00aa00 });
    const person = new THREE.Mesh(personGeometry, personMaterial);
    person.position.y = -0.5;
    person.castShadow = true;
    group.add(person);
    
    // Cordas do paraquedas
    const ropeGeometry = new THREE.CylinderGeometry(0.01, 0.01, 1.2, 4);
    const ropeMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff });
    
    for (let i = 0; i < 4; i++) {
        const rope = new THREE.Mesh(ropeGeometry, ropeMaterial);
        const angle = (i / 4) * Math.PI * 2;
        rope.position.set(Math.cos(angle) * 0.4, 0.2, Math.sin(angle) * 0.4);
        group.add(rope);
    }
    
    return group;
}

// Criar projétil
function createBullet() {
    const geometry = new THREE.SphereGeometry(0.1, 6, 4);
    const material = new THREE.MeshBasicMaterial({ color: 0xffff00 });
    const bullet = new THREE.Mesh(geometry, material);
    return bullet;
}

// Criar campo de estrelas
function createStarField() {
    const starGeometry = new THREE.SphereGeometry(0.02, 4, 4);
    const starMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff });
    
    for (let i = 0; i < 200; i++) {
        const star = new THREE.Mesh(starGeometry, starMaterial);
        star.position.set(
            (Math.random() - 0.5) * 100,
            (Math.random() - 0.5) * 50,
            (Math.random() - 0.5) * 100
        );
        scene.add(star);
        stars.push(star);
    }
}

// Criar explosão
function createExplosion(position) {
    const particles = [];
    const particleGeometry = new THREE.SphereGeometry(0.05, 4, 4);
    
    for (let i = 0; i < 15; i++) {
        const particleMaterial = new THREE.MeshBasicMaterial({ 
            color: new THREE.Color().setHSL(Math.random() * 0.1 + 0.05, 1, 0.5)
        });
        const particle = new THREE.Mesh(particleGeometry, particleMaterial);
        particle.position.copy(position);
        
        const velocity = new THREE.Vector3(
            (Math.random() - 0.5) * 0.3,
            (Math.random() - 0.5) * 0.3,
            (Math.random() - 0.5) * 0.3
        );
        
        particle.userData = {
            velocity: velocity,
            life: 1.0,
            decay: 0.02
        };
        
        scene.add(particle);
        particles.push(particle);
    }
    
    explosions.push(particles);
}

// Spawnar inimigo (disco voador)
function spawnEnemy() {
    if (!gameRunning) return;
    
    const enemy = createUFO();
    enemy.position.set(
        (Math.random() - 0.5) * GAME_WIDTH,
        2,
        -GAME_DEPTH / 2
    );
    enemy.userData = { 
        type: 'ufo', 
        speed: 0.05 + Math.random() * 0.03,
        lastShot: 0,
        shootCooldown: 3000 + Math.random() * 2000 // 3-5 segundos
    };
    scene.add(enemy);
    enemies.push(enemy);
}

// Spawnar avião
function spawnAirplane() {
    if (!gameRunning) return;
    
    const airplane = createAirplane();
    airplane.position.set(
        -GAME_WIDTH / 2 - 2,
        4,
        (Math.random() - 0.5) * GAME_DEPTH * 0.5
    );
    airplane.userData = { 
        type: 'airplane', 
        speed: 0.08,
        lastParachutistDrop: 0
    };
    scene.add(airplane);
    airplanes.push(airplane);
}

// Atirar (jogador)
function shoot() {
    if (!gameRunning) return;
    
    const bullet = createBullet();
    bullet.position.copy(player.position);
    bullet.position.y += 1;
    bullet.position.z -= 1;
    bullet.userData = { speed: 0.3, type: 'player' };
    scene.add(bullet);
    bullets.push(bullet);
}

// Atirar (inimigo)
function enemyShoot(enemy) {
    const bullet = createBullet();
    bullet.material.color.setHex(0xff0000); // Projéteis inimigos são vermelhos
    bullet.position.copy(enemy.position);
    bullet.position.y -= 0.5;
    bullet.position.z += 1;
    bullet.userData = { speed: 0.15, type: 'enemy' };
    scene.add(bullet);
    enemyBullets.push(bullet);
}

// Atualizar cor do jogador
function updatePlayerColor() {
    player.children.forEach(child => {
        if (child.userData.type === 'body') {
            child.material.color.setHex(playerColors[currentColorIndex]);
        }
    });
}

// Jogador foi atingido
function playerHit() {
    playerHits++;
    
    if (playerHits >= 3) {
        // Perder uma vida e resetar cor
        lives--;
        playerHits = 0;
        currentColorIndex = 0;
        
        if (lives <= 0) {
            gameOver();
            return;
        }
    } else {
        // Mudar cor
        currentColorIndex = playerHits;
    }
    
    updatePlayerColor();
    updateUI();
}

// Controles do teclado
function onKeyDown(event) {
    switch(event.code) {
        case 'ArrowLeft':
            keys.left = true;
            break;
        case 'ArrowRight':
            keys.right = true;
            break;
        case 'Space':
            event.preventDefault();
            if (!keys.space) {
                keys.space = true;
                shoot();
            }
            break;
    }
}

function onKeyUp(event) {
    switch(event.code) {
        case 'ArrowLeft':
            keys.left = false;
            break;
        case 'ArrowRight':
            keys.right = false;
            break;
        case 'Space':
            keys.space = false;
            break;
    }
}

// Redimensionar janela
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

// Verificar colisões
function checkCollisions() {
    // Colisões entre projéteis do jogador e inimigos
    for (let i = bullets.length - 1; i >= 0; i--) {
        const bullet = bullets[i];
        
        // Verificar colisão com UFOs
        for (let j = enemies.length - 1; j >= 0; j--) {
            const enemy = enemies[j];
            const distance = bullet.position.distanceTo(enemy.position);
            
            if (distance < 1.5) {
                // Criar explosão
                createExplosion(enemy.position);
                
                // Remover projétil e inimigo
                scene.remove(bullet);
                scene.remove(enemy);
                bullets.splice(i, 1);
                enemies.splice(j, 1);
                
                // Aumentar pontuação
                score += 10;
                updateUI();
                break;
            }
        }
        
        // Verificar colisão com aviões
        for (let j = airplanes.length - 1; j >= 0; j--) {
            const airplane = airplanes[j];
            const distance = bullet.position.distanceTo(airplane.position);
            
            if (distance < 2) {
                // Criar explosão
                createExplosion(airplane.position);
                
                // Remover projétil e avião
                scene.remove(bullet);
                scene.remove(airplane);
                bullets.splice(i, 1);
                airplanes.splice(j, 1);
                
                // Diminuir pontuação
                score -= 5;
                updateUI();
                break;
            }
        }
        
        // Verificar colisão com paraquedistas
        for (let j = parachutists.length - 1; j >= 0; j--) {
            const parachutist = parachutists[j];
            const distance = bullet.position.distanceTo(parachutist.position);
            
            if (distance < 1) {
                // Criar explosão
                createExplosion(parachutist.position);
                
                // Remover projétil e paraquedista
                scene.remove(bullet);
                scene.remove(parachutist);
                bullets.splice(i, 1);
                parachutists.splice(j, 1);
                
                // Diminuir pontuação
                score -= 5;
                updateUI();
                break;
            }
        }
    }
    
    // Colisões entre projéteis inimigos e jogador
    for (let i = enemyBullets.length - 1; i >= 0; i--) {
        const bullet = enemyBullets[i];
        const distance = bullet.position.distanceTo(player.position);
        
        if (distance < 1.2) {
            // Criar explosão pequena no jogador
            createExplosion(player.position);
            
            // Remover projétil inimigo
            scene.remove(bullet);
            enemyBullets.splice(i, 1);
            
            // Jogador foi atingido
            playerHit();
            break;
        }
    }
}

// Atualizar UI
function updateUI() {
    document.getElementById('score').textContent = score;
    document.getElementById('lives').textContent = lives;
    
    // Atualizar estado do jogador
    const colorNames = ['Verde', 'Azul', 'Vermelho'];
    const currentColor = colorNames[currentColorIndex];
    document.getElementById('playerState').textContent = `${currentColor} (${playerHits}/3)`;
}

// Fim de jogo
function gameOver() {
    gameRunning = false;
    document.getElementById('finalScore').textContent = score;
    document.getElementById('gameOver').style.display = 'block';
}

// Reiniciar jogo
function restartGame() {
    // Limpar cena
    enemies.forEach(enemy => scene.remove(enemy));
    bullets.forEach(bullet => scene.remove(bullet));
    enemyBullets.forEach(bullet => scene.remove(bullet));
    airplanes.forEach(airplane => scene.remove(airplane));
    parachutists.forEach(parachutist => scene.remove(parachutist));
    
    // Limpar explosões
    explosions.forEach(explosion => {
        explosion.forEach(particle => scene.remove(particle));
    });
    
    enemies = [];
    bullets = [];
    enemyBullets = [];
    airplanes = [];
    parachutists = [];
    explosions = [];
    
    // Resetar variáveis do jogador
    score = 0;
    lives = 3;
    playerHits = 0;
    currentColorIndex = 0;
    gameRunning = true;
    
    // Resetar cor do jogador
    updatePlayerColor();
    
    // Atualizar UI
    updateUI();
    document.getElementById('gameOver').style.display = 'none';
}

// Loop principal do jogo
function animate() {
    requestAnimationFrame(animate);
    
    if (!gameRunning) {
        renderer.render(scene, camera);
        return;
    }
    
    // Mover jogador
    if (keys.left && player.position.x > -GAME_WIDTH / 2) {
        player.position.x -= 0.2;
    }
    if (keys.right && player.position.x < GAME_WIDTH / 2) {
        player.position.x += 0.2;
    }
    
    // Mover projéteis
    for (let i = bullets.length - 1; i >= 0; i--) {
        const bullet = bullets[i];
        bullet.position.z -= bullet.userData.speed;
        
        // Remover projéteis que saíram da tela
        if (bullet.position.z < -GAME_DEPTH / 2) {
            scene.remove(bullet);
            bullets.splice(i, 1);
        }
    }
    
    // Mover inimigos (UFOs)
    for (let i = enemies.length - 1; i >= 0; i--) {
        const enemy = enemies[i];
        enemy.position.z += enemy.userData.speed;
        enemy.rotation.y += 0.02;
        
        // Inimigos atiram ocasionalmente
        const now = Date.now();
        if (now - enemy.userData.lastShot > enemy.userData.shootCooldown && Math.random() < 0.005) {
            enemyShoot(enemy);
            enemy.userData.lastShot = now;
        }
        
        // Remover inimigos que saíram da tela
        if (enemy.position.z > GAME_DEPTH / 2) {
            scene.remove(enemy);
            enemies.splice(i, 1);
        }
    }
    
    // Mover aviões
    for (let i = airplanes.length - 1; i >= 0; i--) {
        const airplane = airplanes[i];
        airplane.position.x += airplane.userData.speed;
        
        // Soltar paraquedistas ocasionalmente
        if (Math.random() < 0.01 && Date.now() - airplane.userData.lastParachutistDrop > 2000) {
            const parachutist = createParachutist();
            parachutist.position.copy(airplane.position);
            parachutist.position.y -= 1;
            parachutist.userData = { speed: 0.02 };
            scene.add(parachutist);
            parachutists.push(parachutist);
            airplane.userData.lastParachutistDrop = Date.now();
        }
        
        // Remover aviões que saíram da tela
        if (airplane.position.x > GAME_WIDTH / 2 + 2) {
            scene.remove(airplane);
            airplanes.splice(i, 1);
        }
    }
    
    // Mover paraquedistas
    for (let i = parachutists.length - 1; i >= 0; i--) {
        const parachutist = parachutists[i];
        parachutist.position.y -= parachutist.userData.speed;
        parachutist.rotation.y += 0.01;
        
        // Remover paraquedistas que chegaram ao chão
        if (parachutist.position.y < -2) {
            scene.remove(parachutist);
            parachutists.splice(i, 1);
        }
    }
    
    // Mover projéteis inimigos
    for (let i = enemyBullets.length - 1; i >= 0; i--) {
        const bullet = enemyBullets[i];
        bullet.position.z += bullet.userData.speed;
        
        // Remover projéteis que saíram da tela
        if (bullet.position.z > GAME_DEPTH / 2) {
            scene.remove(bullet);
            enemyBullets.splice(i, 1);
        }
    }
    
    // Atualizar explosões
    for (let i = explosions.length - 1; i >= 0; i--) {
        const explosion = explosions[i];
        let allParticlesDead = true;
        
        for (let j = explosion.length - 1; j >= 0; j--) {
            const particle = explosion[j];
            
            // Mover partícula
            particle.position.add(particle.userData.velocity);
            
            // Diminuir vida da partícula
            particle.userData.life -= particle.userData.decay;
            
            // Atualizar opacidade
            particle.material.opacity = particle.userData.life;
            particle.material.transparent = true;
            
            if (particle.userData.life <= 0) {
                scene.remove(particle);
                explosion.splice(j, 1);
            } else {
                allParticlesDead = false;
            }
        }
        
        if (allParticlesDead) {
            explosions.splice(i, 1);
        }
    }
    
    // Animar estrelas (movimento sutil)
    stars.forEach(star => {
        star.rotation.x += 0.001;
        star.rotation.y += 0.001;
    });
    
    // Verificar colisões
    checkCollisions();
    
    // Renderizar
    renderer.render(scene, camera);
}

// Inicializar jogo quando a página carregar
window.addEventListener('load', init);