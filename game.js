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

// Criar jogador (robô futurista 3D)
function createPlayer() {
    const group = new THREE.Group();
    
    // Corpo principal metálico
    const bodyGeometry = new THREE.BoxGeometry(0.8, 1.2, 0.6);
    const bodyMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x666666,
        shininess: 100,
        specular: 0x444444
    });
    const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
    body.position.y = 0.6;
    body.castShadow = true;
    body.userData = { type: 'body' };
    group.add(body);
    
    // Detalhes neon no corpo
    const neonGeometry = new THREE.BoxGeometry(0.82, 0.1, 0.62);
    const neonMaterial = new THREE.MeshBasicMaterial({ 
        color: playerColors[currentColorIndex],
        transparent: true,
        opacity: 0.8
    });
    const neonStripe1 = new THREE.Mesh(neonGeometry, neonMaterial);
    neonStripe1.position.set(0, 0.8, 0);
    neonStripe1.userData = { type: 'neon' };
    group.add(neonStripe1);
    
    const neonStripe2 = new THREE.Mesh(neonGeometry, neonMaterial);
    neonStripe2.position.set(0, 0.4, 0);
    neonStripe2.userData = { type: 'neon' };
    group.add(neonStripe2);
    
    // Capacete/Cabeça robótica
    const headGeometry = new THREE.BoxGeometry(0.6, 0.6, 0.6);
    const headMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x888888,
        shininess: 150,
        specular: 0x666666
    });
    const head = new THREE.Mesh(headGeometry, headMaterial);
    head.position.y = 1.5;
    head.castShadow = true;
    group.add(head);
    
    // Visor transparente azul
    const visorGeometry = new THREE.BoxGeometry(0.5, 0.3, 0.61);
    const visorMaterial = new THREE.MeshBasicMaterial({ 
        color: 0x00aaff,
        transparent: true,
        opacity: 0.6
    });
    const visor = new THREE.Mesh(visorGeometry, visorMaterial);
    visor.position.set(0, 1.5, 0);
    group.add(visor);
    
    // Braços robóticos
    const armGeometry = new THREE.BoxGeometry(0.2, 0.8, 0.2);
    const armMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x555555,
        shininess: 80
    });
    
    const leftArm = new THREE.Mesh(armGeometry, armMaterial);
    leftArm.position.set(-0.6, 1, 0);
    leftArm.castShadow = true;
    group.add(leftArm);
    
    const rightArm = new THREE.Mesh(armGeometry, armMaterial);
    rightArm.position.set(0.6, 1, 0);
    rightArm.castShadow = true;
    group.add(rightArm);
    
    // Pernas robóticas
    const legGeometry = new THREE.BoxGeometry(0.25, 0.8, 0.25);
    const legMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x555555,
        shininess: 80
    });
    
    const leftLeg = new THREE.Mesh(legGeometry, legMaterial);
    leftLeg.position.set(-0.25, -0.4, 0);
    leftLeg.castShadow = true;
    group.add(leftLeg);
    
    const rightLeg = new THREE.Mesh(legGeometry, legMaterial);
    rightLeg.position.set(0.25, -0.4, 0);
    rightLeg.castShadow = true;
    group.add(rightLeg);
    
    // Jatos propulsores nas costas
    const jetGeometry = new THREE.CylinderGeometry(0.1, 0.15, 0.4, 8);
    const jetMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x333333,
        shininess: 100
    });
    
    const leftJet = new THREE.Mesh(jetGeometry, jetMaterial);
    leftJet.position.set(-0.2, 0.6, -0.4);
    leftJet.rotation.x = Math.PI / 2;
    leftJet.castShadow = true;
    group.add(leftJet);
    
    const rightJet = new THREE.Mesh(jetGeometry, jetMaterial);
    rightJet.position.set(0.2, 0.6, -0.4);
    rightJet.rotation.x = Math.PI / 2;
    rightJet.castShadow = true;
    group.add(rightJet);
    
    // Efeito de propulsão (partículas azuis)
    const thrustGeometry = new THREE.ConeGeometry(0.08, 0.3, 6);
    const thrustMaterial = new THREE.MeshBasicMaterial({ 
        color: 0x00aaff,
        transparent: true,
        opacity: 0.7
    });
    
    const leftThrust = new THREE.Mesh(thrustGeometry, thrustMaterial);
    leftThrust.position.set(-0.2, 0.6, -0.7);
    leftThrust.rotation.x = Math.PI / 2;
    leftThrust.userData = { type: 'thrust' };
    group.add(leftThrust);
    
    const rightThrust = new THREE.Mesh(thrustGeometry, thrustMaterial);
    rightThrust.position.set(0.2, 0.6, -0.7);
    rightThrust.rotation.x = Math.PI / 2;
    rightThrust.userData = { type: 'thrust' };
    group.add(rightThrust);
    
    group.position.set(0, 0, 8);
    scene.add(group);
    player = group;
}

// Criar disco voador inimigo (UFO clássico detalhado)
function createUFO() {
    const group = new THREE.Group();
    
    // Corpo principal do disco (mais detalhado)
    const bodyGeometry = new THREE.CylinderGeometry(1.2, 1.8, 0.4, 24);
    const bodyMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x888888,
        shininess: 120,
        specular: 0x666666
    });
    const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
    body.castShadow = true;
    group.add(body);
    
    // Anel metálico no meio
    const ringGeometry = new THREE.TorusGeometry(1.5, 0.1, 8, 24);
    const ringMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x444444,
        shininess: 150
    });
    const ring = new THREE.Mesh(ringGeometry, ringMaterial);
    ring.rotation.x = Math.PI / 2;
    ring.castShadow = true;
    group.add(ring);
    
    // Cúpula superior cristalina
    const domeGeometry = new THREE.SphereGeometry(1, 16, 8, 0, Math.PI * 2, 0, Math.PI / 2);
    const domeMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x00ffff, 
        transparent: true, 
        opacity: 0.6,
        shininess: 200
    });
    const dome = new THREE.Mesh(domeGeometry, domeMaterial);
    dome.position.y = 0.3;
    dome.castShadow = true;
    group.add(dome);
    
    // Interior iluminado da cúpula
    const innerLightGeometry = new THREE.SphereGeometry(0.8, 12, 6);
    const innerLightMaterial = new THREE.MeshBasicMaterial({ 
        color: 0x00aaff,
        transparent: true,
        opacity: 0.3
    });
    const innerLight = new THREE.Mesh(innerLightGeometry, innerLightMaterial);
    innerLight.position.y = 0.3;
    group.add(innerLight);
    
    // Luzes rotativas coloridas na borda (mais detalhadas)
    const lightColors = [0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0xff00ff, 0x00ffff];
    
    for (let i = 0; i < 8; i++) {
        const lightGeometry = new THREE.SphereGeometry(0.12, 8, 6);
        const lightMaterial = new THREE.MeshBasicMaterial({ 
            color: lightColors[i % lightColors.length]
        });
        const light = new THREE.Mesh(lightGeometry, lightMaterial);
        const angle = (i / 8) * Math.PI * 2;
        light.position.set(Math.cos(angle) * 1.4, 0, Math.sin(angle) * 1.4);
        light.userData = { type: 'rotatingLight', angle: angle };
        group.add(light);
        
        // Halo ao redor de cada luz
        const haloGeometry = new THREE.SphereGeometry(0.18, 8, 6);
        const haloMaterial = new THREE.MeshBasicMaterial({ 
            color: lightColors[i % lightColors.length],
            transparent: true,
            opacity: 0.3
        });
        const halo = new THREE.Mesh(haloGeometry, haloMaterial);
        halo.position.copy(light.position);
        group.add(halo);
    }
    
    // Base inferior metálica
    const baseGeometry = new THREE.CylinderGeometry(0.8, 1.2, 0.2, 16);
    const baseMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x666666,
        shininess: 100
    });
    const base = new THREE.Mesh(baseGeometry, baseMaterial);
    base.position.y = -0.3;
    base.castShadow = true;
    group.add(base);
    
    // Detalhes tecnológicos na base
    for (let i = 0; i < 4; i++) {
        const detailGeometry = new THREE.BoxGeometry(0.1, 0.05, 0.3);
        const detailMaterial = new THREE.MeshPhongMaterial({ 
            color: 0x333333,
            shininess: 80
        });
        const detail = new THREE.Mesh(detailGeometry, detailMaterial);
        const angle = (i / 4) * Math.PI * 2;
        detail.position.set(Math.cos(angle) * 1, -0.3, Math.sin(angle) * 1);
        detail.rotation.y = angle;
        group.add(detail);
    }
    
    return group;
}

// Criar nave de combate sci-fi
function createAirplane() {
    const group = new THREE.Group();
    
    // Fuselagem principal angular
    const bodyGeometry = new THREE.BoxGeometry(2.5, 0.4, 0.8);
    const bodyMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x1a237e,
        shininess: 100,
        specular: 0x3f51b5
    });
    const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
    body.castShadow = true;
    group.add(body);
    
    // Cockpit frontal
    const cockpitGeometry = new THREE.BoxGeometry(0.8, 0.3, 0.6);
    const cockpitMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x0d47a1,
        shininess: 150
    });
    const cockpit = new THREE.Mesh(cockpitGeometry, cockpitMaterial);
    cockpit.position.set(1.2, 0.1, 0);
    cockpit.castShadow = true;
    group.add(cockpit);
    
    // Visor do cockpit
    const visorGeometry = new THREE.BoxGeometry(0.6, 0.2, 0.5);
    const visorMaterial = new THREE.MeshBasicMaterial({ 
        color: 0x00aaff,
        transparent: true,
        opacity: 0.7
    });
    const visor = new THREE.Mesh(visorGeometry, visorMaterial);
    visor.position.set(1.2, 0.15, 0);
    group.add(visor);
    
    // Asas angulares futuristas
    const wingGeometry = new THREE.BoxGeometry(4, 0.15, 1.2);
    const wingMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x283593,
        shininess: 80
    });
    const wings = new THREE.Mesh(wingGeometry, wingMaterial);
    wings.position.set(-0.3, 0, 0);
    wings.castShadow = true;
    group.add(wings);
    
    // Propulsores de energia (2 principais)
    const thrusterGeometry = new THREE.CylinderGeometry(0.15, 0.2, 0.6, 8);
    const thrusterMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x37474f,
        shininess: 120
    });
    
    const leftThruster = new THREE.Mesh(thrusterGeometry, thrusterMaterial);
    leftThruster.position.set(-1.5, 0, -0.4);
    leftThruster.rotation.z = Math.PI / 2;
    leftThruster.castShadow = true;
    group.add(leftThruster);
    
    const rightThruster = new THREE.Mesh(thrusterGeometry, thrusterMaterial);
    rightThruster.position.set(-1.5, 0, 0.4);
    rightThruster.rotation.z = Math.PI / 2;
    rightThruster.castShadow = true;
    group.add(rightThruster);
    
    // Efeitos de energia dos propulsores
    const energyGeometry = new THREE.ConeGeometry(0.12, 0.4, 6);
    const energyMaterial = new THREE.MeshBasicMaterial({ 
        color: 0xff6d00,
        transparent: true,
        opacity: 0.8
    });
    
    const leftEnergy = new THREE.Mesh(energyGeometry, energyMaterial);
    leftEnergy.position.set(-1.9, 0, -0.4);
    leftEnergy.rotation.z = -Math.PI / 2;
    leftEnergy.userData = { type: 'energy' };
    group.add(leftEnergy);
    
    const rightEnergy = new THREE.Mesh(energyGeometry, energyMaterial);
    rightEnergy.position.set(-1.9, 0, 0.4);
    rightEnergy.rotation.z = -Math.PI / 2;
    rightEnergy.userData = { type: 'energy' };
    group.add(rightEnergy);
    
    // Armas de plasma nas asas
    const weaponGeometry = new THREE.BoxGeometry(0.3, 0.1, 0.1);
    const weaponMaterial = new THREE.MeshPhongMaterial({ 
        color: 0xff5722,
        shininess: 150
    });
    
    // Armas esquerdas
    const leftWeapon1 = new THREE.Mesh(weaponGeometry, weaponMaterial);
    leftWeapon1.position.set(0.5, 0, -1.8);
    group.add(leftWeapon1);
    
    const leftWeapon2 = new THREE.Mesh(weaponGeometry, weaponMaterial);
    leftWeapon2.position.set(0, 0, -1.5);
    group.add(leftWeapon2);
    
    // Armas direitas
    const rightWeapon1 = new THREE.Mesh(weaponGeometry, weaponMaterial);
    rightWeapon1.position.set(0.5, 0, 1.8);
    group.add(rightWeapon1);
    
    const rightWeapon2 = new THREE.Mesh(weaponGeometry, weaponMaterial);
    rightWeapon2.position.set(0, 0, 1.5);
    group.add(rightWeapon2);
    
    // Detalhes luminosos na fuselagem
    const detailGeometry = new THREE.BoxGeometry(2.2, 0.05, 0.1);
    const detailMaterial = new THREE.MeshBasicMaterial({ 
        color: 0x00e676,
        transparent: true,
        opacity: 0.9
    });
    
    const topDetail = new THREE.Mesh(detailGeometry, detailMaterial);
    topDetail.position.set(0, 0.25, 0);
    group.add(topDetail);
    
    const bottomDetail = new THREE.Mesh(detailGeometry, detailMaterial);
    bottomDetail.position.set(0, -0.25, 0);
    group.add(bottomDetail);
    
    // Estabilizadores traseiros
    const stabilizerGeometry = new THREE.BoxGeometry(0.4, 0.6, 0.1);
    const stabilizerMaterial = new THREE.MeshPhongMaterial({ 
        color: 0x1a237e,
        shininess: 100
    });
    
    const topStabilizer = new THREE.Mesh(stabilizerGeometry, stabilizerMaterial);
    topStabilizer.position.set(-1.2, 0.4, 0);
    topStabilizer.castShadow = true;
    group.add(topStabilizer);
    
    return group;
}

// Criar paraquedista
function createParachutist() {
    const parachutist = new THREE.Group();
    
    // === SOLDADO DETALHADO ===
    
    // Corpo principal (torso militar)
    const torsoGeometry = new THREE.BoxGeometry(0.8, 1.2, 0.4);
    const torsoMaterial = new THREE.MeshLambertMaterial({ color: 0x2F4F2F }); // Verde militar
    const torso = new THREE.Mesh(torsoGeometry, torsoMaterial);
    torso.position.y = 0;
    parachutist.add(torso);
    
    // Cabeça com capacete
    const headGeometry = new THREE.SphereGeometry(0.25, 8, 6);
    const headMaterial = new THREE.MeshLambertMaterial({ color: 0xFFDBB5 }); // Cor da pele
    const head = new THREE.Mesh(headGeometry, headMaterial);
    head.position.y = 0.85;
    parachutist.add(head);
    
    // Capacete militar
    const helmetGeometry = new THREE.SphereGeometry(0.28, 8, 6);
    const helmetMaterial = new THREE.MeshLambertMaterial({ color: 0x1C3A1C });
    const helmet = new THREE.Mesh(helmetGeometry, helmetMaterial);
    helmet.position.y = 0.85;
    parachutist.add(helmet);
    
    // Braços
    const armGeometry = new THREE.CylinderGeometry(0.15, 0.15, 0.8, 6);
    const armMaterial = new THREE.MeshLambertMaterial({ color: 0x2F4F2F });
    
    const leftArm = new THREE.Mesh(armGeometry, armMaterial);
    leftArm.position.set(-0.5, 0.2, 0);
    leftArm.rotation.z = 0.3;
    parachutist.add(leftArm);
    
    const rightArm = new THREE.Mesh(armGeometry, armMaterial);
    rightArm.position.set(0.5, 0.2, 0);
    rightArm.rotation.z = -0.3;
    parachutist.add(rightArm);
    
    // Pernas
    const legGeometry = new THREE.CylinderGeometry(0.18, 0.18, 1.0, 6);
    const legMaterial = new THREE.MeshLambertMaterial({ color: 0x2F4F2F });
    
    const leftLeg = new THREE.Mesh(legGeometry, legMaterial);
    leftLeg.position.set(-0.25, -1.1, 0);
    parachutist.add(leftLeg);
    
    const rightLeg = new THREE.Mesh(legGeometry, legMaterial);
    rightLeg.position.set(0.25, -1.1, 0);
    parachutist.add(rightLeg);
    
    // Botas militares
    const bootGeometry = new THREE.BoxGeometry(0.3, 0.2, 0.5);
    const bootMaterial = new THREE.MeshLambertMaterial({ color: 0x000000 });
    
    const leftBoot = new THREE.Mesh(bootGeometry, bootMaterial);
    leftBoot.position.set(-0.25, -1.7, 0.1);
    parachutist.add(leftBoot);
    
    const rightBoot = new THREE.Mesh(bootGeometry, bootMaterial);
    rightBoot.position.set(0.25, -1.7, 0.1);
    parachutist.add(rightBoot);
    
    // Equipamentos militares
    // Mochila
    const backpackGeometry = new THREE.BoxGeometry(0.6, 0.8, 0.3);
    const backpackMaterial = new THREE.MeshLambertMaterial({ color: 0x1C3A1C });
    const backpack = new THREE.Mesh(backpackGeometry, backpackMaterial);
    backpack.position.set(0, 0.1, -0.35);
    parachutist.add(backpack);
    
    // Rifle nas costas
    const rifleGeometry = new THREE.CylinderGeometry(0.03, 0.03, 1.2);
    const rifleMaterial = new THREE.MeshLambertMaterial({ color: 0x2C2C2C });
    const rifle = new THREE.Mesh(rifleGeometry, rifleMaterial);
    rifle.position.set(0.2, 0.3, -0.5);
    rifle.rotation.x = Math.PI / 6;
    parachutist.add(rifle);
    
    // === PARAQUEDAS MILITAR DETALHADO ===
    
    // Cúpula principal do paraquedas (formato mais realista)
    const parachuteGeometry = new THREE.SphereGeometry(3.5, 16, 8, 0, Math.PI * 2, 0, Math.PI / 2);
    const parachuteMaterial = new THREE.MeshLambertMaterial({ 
        color: 0x8B0000, // Vermelho escuro militar
        transparent: true,
        opacity: 0.9
    });
    const parachute = new THREE.Mesh(parachuteGeometry, parachuteMaterial);
    parachute.position.y = 4;
    parachute.rotation.x = Math.PI;
    parachutist.add(parachute);
    
    // Listras no paraquedas para realismo
    for (let i = 0; i < 8; i++) {
        const stripeGeometry = new THREE.SphereGeometry(3.6, 16, 8, i * Math.PI / 4, Math.PI / 8, 0, Math.PI / 2);
        const stripeMaterial = new THREE.MeshLambertMaterial({ 
            color: i % 2 === 0 ? 0xFF4500 : 0x8B0000,
            transparent: true,
            opacity: 0.8
        });
        const stripe = new THREE.Mesh(stripeGeometry, stripeMaterial);
        stripe.position.y = 4;
        stripe.rotation.x = Math.PI;
        parachutist.add(stripe);
    }
    
    // Cordas do paraquedas (mais realistas)
    for (let i = 0; i < 12; i++) {
        const ropeGeometry = new THREE.CylinderGeometry(0.02, 0.02, 3.2);
        const ropeMaterial = new THREE.MeshLambertMaterial({ color: 0x8B4513 });
        const rope = new THREE.Mesh(ropeGeometry, ropeMaterial);
        
        const angle = (i / 12) * Math.PI * 2;
        const radius = 2.2;
        rope.position.x = Math.cos(angle) * radius;
        rope.position.z = Math.sin(angle) * radius;
        rope.position.y = 2.4;
        
        // Inclinar as cordas para parecer mais natural
        rope.rotation.x = 0.1;
        rope.rotation.z = Math.sin(angle) * 0.1;
        
        parachutist.add(rope);
    }
    
    // Arnês do paraquedas
    const harnessGeometry = new THREE.TorusGeometry(0.4, 0.05, 8, 16);
    const harnessMaterial = new THREE.MeshLambertMaterial({ color: 0x654321 });
    const harness = new THREE.Mesh(harnessGeometry, harnessMaterial);
    harness.position.y = 0.2;
    harness.rotation.x = Math.PI / 2;
    parachutist.add(harness);
    
    // Conectores do arnês
    for (let i = 0; i < 4; i++) {
        const connectorGeometry = new THREE.BoxGeometry(0.1, 0.1, 0.1);
        const connectorMaterial = new THREE.MeshLambertMaterial({ color: 0x2C2C2C });
        const connector = new THREE.Mesh(connectorGeometry, connectorMaterial);
        
        const angle = (i / 4) * Math.PI * 2;
        connector.position.x = Math.cos(angle) * 0.4;
        connector.position.z = Math.sin(angle) * 0.4;
        connector.position.y = 0.2;
        parachutist.add(connector);
    }
    
    return parachutist;
}

// Criar projétil
function createBullet() {
    const bullet = new THREE.Group();
    
    // === LASER ENERGÉTICO FUTURISTA ===
    
    // Núcleo central do laser (energia pura)
    const coreGeometry = new THREE.CylinderGeometry(0.08, 0.08, 1.5, 8);
    const coreMaterial = new THREE.MeshLambertMaterial({ 
        color: 0x00FFFF, // Ciano brilhante
        emissive: 0x004444,
        transparent: true,
        opacity: 0.9
    });
    const core = new THREE.Mesh(coreGeometry, coreMaterial);
    core.rotation.x = Math.PI / 2;
    bullet.add(core);
    
    // Halo externo do laser (efeito de energia)
    const haloGeometry = new THREE.CylinderGeometry(0.15, 0.15, 1.6, 8);
    const haloMaterial = new THREE.MeshLambertMaterial({ 
        color: 0x00AAFF,
        emissive: 0x002233,
        transparent: true,
        opacity: 0.4
    });
    const halo = new THREE.Mesh(haloGeometry, haloMaterial);
    halo.rotation.x = Math.PI / 2;
    bullet.add(halo);
    
    // Ponta do laser (concentração de energia)
    const tipGeometry = new THREE.ConeGeometry(0.12, 0.3, 8);
    const tipMaterial = new THREE.MeshLambertMaterial({ 
        color: 0xFFFFFF, // Branco puro na ponta
        emissive: 0x666666,
        transparent: true,
        opacity: 0.8
    });
    const tip = new THREE.Mesh(tipGeometry, tipMaterial);
    tip.position.z = 0.9;
    tip.rotation.x = Math.PI / 2;
    bullet.add(tip);
    
    // Cauda do laser (rastro de energia)
    const tailGeometry = new THREE.ConeGeometry(0.05, 0.4, 6);
    const tailMaterial = new THREE.MeshLambertMaterial({ 
        color: 0x0088CC,
        emissive: 0x001122,
        transparent: true,
        opacity: 0.6
    });
    const tail = new THREE.Mesh(tailGeometry, tailMaterial);
    tail.position.z = -0.9;
    tail.rotation.x = -Math.PI / 2;
    bullet.add(tail);
    
    // Anéis de energia ao longo do laser
    for (let i = 0; i < 3; i++) {
        const ringGeometry = new THREE.TorusGeometry(0.12, 0.02, 8, 16);
        const ringMaterial = new THREE.MeshLambertMaterial({ 
            color: 0x00FFAA,
            emissive: 0x003333,
            transparent: true,
            opacity: 0.7
        });
        const ring = new THREE.Mesh(ringGeometry, ringMaterial);
        ring.position.z = -0.4 + (i * 0.4);
        ring.rotation.x = Math.PI / 2;
        bullet.add(ring);
    }
    
    // Partículas de energia (pequenas esferas brilhantes)
    for (let i = 0; i < 6; i++) {
        const particleGeometry = new THREE.SphereGeometry(0.03, 6, 4);
        const particleMaterial = new THREE.MeshLambertMaterial({ 
            color: 0x00FFFF,
            emissive: 0x004444,
            transparent: true,
            opacity: 0.8
        });
        const particle = new THREE.Mesh(particleGeometry, particleMaterial);
        
        // Posicionar partículas aleatoriamente ao redor do laser
        const angle = (i / 6) * Math.PI * 2;
        particle.position.x = Math.cos(angle) * 0.2;
        particle.position.y = Math.sin(angle) * 0.2;
        particle.position.z = -0.6 + (Math.random() * 1.2);
        bullet.add(particle);
    }
    
    // Efeito de distorção na base do laser
    const baseGeometry = new THREE.SphereGeometry(0.1, 8, 6);
    const baseMaterial = new THREE.MeshLambertMaterial({ 
        color: 0xFFFFFF,
        emissive: 0x888888,
        transparent: true,
        opacity: 0.9
    });
    const base = new THREE.Mesh(baseGeometry, baseMaterial);
    base.position.z = -0.75;
    bullet.add(base);
    
    return bullet;
}

// Criar campo de estrelas
function createStarField() {
    // === CAMPO DE ESTRELAS MELHORADO ===
    
    // Estrelas distantes (pequenas e brilhantes)
    for (let i = 0; i < 150; i++) {
        const starGeometry = new THREE.SphereGeometry(0.015, 6, 4);
        const starMaterial = new THREE.MeshLambertMaterial({ 
            color: 0xFFFFFF,
            emissive: 0x222222,
            transparent: true,
            opacity: Math.random() * 0.8 + 0.2
        });
        const star = new THREE.Mesh(starGeometry, starMaterial);
        star.position.set(
            (Math.random() - 0.5) * 120,
            (Math.random() - 0.5) * 60,
            (Math.random() - 0.5) * 120
        );
        
        // Adicionar piscada aleatória
        star.userData = {
            twinkleSpeed: Math.random() * 0.02 + 0.01,
            twinklePhase: Math.random() * Math.PI * 2,
            baseOpacity: star.material.opacity
        };
        
        scene.add(star);
        stars.push(star);
    }
    
    // Estrelas médias (coloridas)
    for (let i = 0; i < 80; i++) {
        const starGeometry = new THREE.SphereGeometry(0.025, 6, 4);
        const hue = Math.random();
        const starMaterial = new THREE.MeshLambertMaterial({ 
            color: new THREE.Color().setHSL(hue, 0.6, 0.8),
            emissive: new THREE.Color().setHSL(hue, 0.4, 0.2),
            transparent: true,
            opacity: Math.random() * 0.6 + 0.4
        });
        const star = new THREE.Mesh(starGeometry, starMaterial);
        star.position.set(
            (Math.random() - 0.5) * 100,
            (Math.random() - 0.5) * 50,
            (Math.random() - 0.5) * 100
        );
        
        star.userData = {
            twinkleSpeed: Math.random() * 0.015 + 0.008,
            twinklePhase: Math.random() * Math.PI * 2,
            baseOpacity: star.material.opacity,
            rotationSpeed: Math.random() * 0.005 + 0.001
        };
        
        scene.add(star);
        stars.push(star);
    }
    
    // Estrelas grandes (brilhantes e próximas)
    for (let i = 0; i < 30; i++) {
        const starGeometry = new THREE.SphereGeometry(0.04, 8, 6);
        const hue = Math.random();
        const starMaterial = new THREE.MeshLambertMaterial({ 
            color: new THREE.Color().setHSL(hue, 0.8, 0.9),
            emissive: new THREE.Color().setHSL(hue, 0.6, 0.4),
            transparent: true,
            opacity: Math.random() * 0.4 + 0.6
        });
        const star = new THREE.Mesh(starGeometry, starMaterial);
        star.position.set(
            (Math.random() - 0.5) * 80,
            (Math.random() - 0.5) * 40,
            (Math.random() - 0.5) * 80
        );
        
        // Adicionar halo de luz
        const haloGeometry = new THREE.SphereGeometry(0.08, 8, 6);
        const haloMaterial = new THREE.MeshLambertMaterial({ 
            color: new THREE.Color().setHSL(hue, 0.5, 0.7),
            transparent: true,
            opacity: 0.2
        });
        const halo = new THREE.Mesh(haloGeometry, haloMaterial);
        star.add(halo);
        
        star.userData = {
            twinkleSpeed: Math.random() * 0.01 + 0.005,
            twinklePhase: Math.random() * Math.PI * 2,
            baseOpacity: star.material.opacity,
            rotationSpeed: Math.random() * 0.008 + 0.002,
            halo: halo
        };
        
        scene.add(star);
        stars.push(star);
    }
    
    // Nebulosas distantes (efeito de fundo)
    for (let i = 0; i < 10; i++) {
        const nebulaGeometry = new THREE.SphereGeometry(2, 8, 6);
        const hue = Math.random() * 0.3 + 0.5; // Tons azuis/roxos
        const nebulaMaterial = new THREE.MeshLambertMaterial({ 
            color: new THREE.Color().setHSL(hue, 0.7, 0.3),
            transparent: true,
            opacity: 0.1
        });
        const nebula = new THREE.Mesh(nebulaGeometry, nebulaMaterial);
        nebula.position.set(
            (Math.random() - 0.5) * 200,
            (Math.random() - 0.5) * 100,
            (Math.random() - 0.5) * 200
        );
        
        nebula.userData = {
            rotationSpeed: Math.random() * 0.002 + 0.0005
        };
        
        scene.add(nebula);
        stars.push(nebula);
    }
}

// Criar explosão
function createExplosion(position) {
    const particles = [];
    
    // === EXPLOSÃO ESPETACULAR COM MÚLTIPLOS EFEITOS ===
    
    // 1. NÚCLEO DA EXPLOSÃO (esfera brilhante central)
    const coreGeometry = new THREE.SphereGeometry(0.3, 8, 6);
    const coreMaterial = new THREE.MeshLambertMaterial({ 
        color: 0xFFFFFF,
        emissive: 0xFFAA00,
        transparent: true,
        opacity: 1.0
    });
    const core = new THREE.Mesh(coreGeometry, coreMaterial);
    core.position.copy(position);
    core.userData = {
        velocity: new THREE.Vector3(0, 0, 0),
        life: 1.0,
        decay: 0.05,
        scale: 1.0,
        scaleSpeed: 3.0
    };
    scene.add(core);
    particles.push(core);
    
    // 2. ANEL DE CHOQUE (expansão circular)
    const shockGeometry = new THREE.TorusGeometry(0.1, 0.05, 8, 16);
    const shockMaterial = new THREE.MeshLambertMaterial({ 
        color: 0x00AAFF,
        emissive: 0x0066AA,
        transparent: true,
        opacity: 0.8
    });
    const shock = new THREE.Mesh(shockGeometry, shockMaterial);
    shock.position.copy(position);
    shock.userData = {
        velocity: new THREE.Vector3(0, 0, 0),
        life: 1.0,
        decay: 0.03,
        scale: 0.1,
        scaleSpeed: 8.0
    };
    scene.add(shock);
    particles.push(shock);
    
    // 3. PARTÍCULAS DE FOGO (esferas coloridas quentes)
    for (let i = 0; i < 20; i++) {
        const fireGeometry = new THREE.SphereGeometry(0.08, 6, 4);
        const fireMaterial = new THREE.MeshLambertMaterial({ 
            color: new THREE.Color().setHSL(Math.random() * 0.15, 1, 0.6), // Tons de laranja/vermelho
            emissive: new THREE.Color().setHSL(Math.random() * 0.15, 0.8, 0.3),
            transparent: true,
            opacity: 1.0
        });
        const fire = new THREE.Mesh(fireGeometry, fireMaterial);
        fire.position.copy(position);
        
        const velocity = new THREE.Vector3(
            (Math.random() - 0.5) * 0.6,
            (Math.random() - 0.5) * 0.6,
            (Math.random() - 0.5) * 0.6
        );
        
        fire.userData = {
            velocity: velocity,
            life: 1.0,
            decay: 0.025,
            gravity: -0.01
        };
        
        scene.add(fire);
        particles.push(fire);
    }
    
    // 4. FAGULHAS BRILHANTES (pequenas partículas rápidas)
    for (let i = 0; i < 30; i++) {
        const sparkGeometry = new THREE.SphereGeometry(0.03, 4, 3);
        const sparkMaterial = new THREE.MeshLambertMaterial({ 
            color: 0xFFFF00,
            emissive: 0xFFAA00,
            transparent: true,
            opacity: 1.0
        });
        const spark = new THREE.Mesh(sparkGeometry, sparkMaterial);
        spark.position.copy(position);
        
        const velocity = new THREE.Vector3(
            (Math.random() - 0.5) * 1.2,
            (Math.random() - 0.5) * 1.2,
            (Math.random() - 0.5) * 1.2
        );
        
        spark.userData = {
            velocity: velocity,
            life: 1.0,
            decay: 0.04,
            gravity: -0.02
        };
        
        scene.add(spark);
        particles.push(spark);
    }
    
    // 5. FUMAÇA (partículas escuras que sobem)
    for (let i = 0; i < 15; i++) {
        const smokeGeometry = new THREE.SphereGeometry(0.12, 6, 4);
        const smokeMaterial = new THREE.MeshLambertMaterial({ 
            color: new THREE.Color().setHSL(0, 0, Math.random() * 0.3 + 0.1), // Tons de cinza
            transparent: true,
            opacity: 0.6
        });
        const smoke = new THREE.Mesh(smokeGeometry, smokeMaterial);
        smoke.position.copy(position);
        smoke.position.y += Math.random() * 0.2;
        
        const velocity = new THREE.Vector3(
            (Math.random() - 0.5) * 0.2,
            Math.random() * 0.3 + 0.1, // Sempre para cima
            (Math.random() - 0.5) * 0.2
        );
        
        smoke.userData = {
            velocity: velocity,
            life: 1.0,
            decay: 0.015,
            scale: 1.0,
            scaleSpeed: 1.5
        };
        
        scene.add(smoke);
        particles.push(smoke);
    }
    
    // 6. FRAGMENTOS METÁLICOS (para explosões de naves)
    for (let i = 0; i < 12; i++) {
        const fragmentGeometry = new THREE.BoxGeometry(0.05, 0.05, 0.15);
        const fragmentMaterial = new THREE.MeshLambertMaterial({ 
            color: 0x888888,
            transparent: true,
            opacity: 1.0
        });
        const fragment = new THREE.Mesh(fragmentGeometry, fragmentMaterial);
        fragment.position.copy(position);
        
        const velocity = new THREE.Vector3(
            (Math.random() - 0.5) * 0.8,
            Math.random() * 0.4,
            (Math.random() - 0.5) * 0.8
        );
        
        fragment.userData = {
            velocity: velocity,
            life: 1.0,
            decay: 0.02,
            gravity: -0.015,
            rotationSpeed: new THREE.Vector3(
                Math.random() * 0.2,
                Math.random() * 0.2,
                Math.random() * 0.2
            )
        };
        
        scene.add(fragment);
        particles.push(fragment);
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
    
    // Efeito sonoro do tiro do jogador
    if (typeof audioSystem !== 'undefined') {
        audioSystem.playPlayerShoot();
    }
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
    console.log(`Enemy shot! Bullet created at: ${bullet.position.x.toFixed(2)}, ${bullet.position.y.toFixed(2)}, ${bullet.position.z.toFixed(2)}`);
    console.log(`Total enemy bullets: ${enemyBullets.length}`);
    
    // Efeito sonoro do tiro do inimigo
    if (typeof audioSystem !== 'undefined') {
        audioSystem.playEnemyShoot();
    }
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
    
    // Efeito sonoro quando jogador é atingido
    if (typeof audioSystem !== 'undefined') {
        audioSystem.playPlayerHit();
    }
    
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
                
                // Efeito sonoro quando inimigo é atingido
                if (typeof audioSystem !== 'undefined') {
                    audioSystem.playEnemyHit();
                }
                
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
    
    // Colisões entre projéteis inimigos e o jogador
    for (let i = enemyBullets.length - 1; i >= 0; i--) {
        const bullet = enemyBullets[i];
        const distance = bullet.position.distanceTo(player.position);
        
        // Debug: adicionar log para verificar colisões
        console.log(`Enemy bullet at: ${bullet.position.x.toFixed(2)}, ${bullet.position.y.toFixed(2)}, ${bullet.position.z.toFixed(2)}`);
        console.log(`Player at: ${player.position.x.toFixed(2)}, ${player.position.y.toFixed(2)}, ${player.position.z.toFixed(2)}`);
        console.log(`Distance: ${distance.toFixed(2)}`);
        
        if (distance < 2) { // Aumentando a distância de colisão
            // Criar explosão na posição do jogador
            createExplosion(player.position);
            
            // Remover projétil inimigo
            scene.remove(bullet);
            enemyBullets.splice(i, 1);
            
            // Jogador foi atingido
            playerHit();
            console.log('Player hit by enemy bullet!');
            break;
        }
    }
}

// Atualizar UI
function updateUI() {
    document.getElementById('score').textContent = score;
    document.getElementById('lives').textContent = lives;
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
    
    enemies = [];
    bullets = [];
    enemyBullets = [];
    airplanes = [];
    parachutists = [];
    
    // Resetar variáveis
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
    
    // Mover projéteis inimigos
    for (let i = enemyBullets.length - 1; i >= 0; i--) {
        const bullet = enemyBullets[i];
        bullet.position.z += bullet.userData.speed;
        
        // Remover projéteis inimigos que saíram da tela
        if (bullet.position.z > GAME_DEPTH / 2) {
            scene.remove(bullet);
            enemyBullets.splice(i, 1);
        }
    }
    
    // Mover inimigos (UFOs)
    for (let i = enemies.length - 1; i >= 0; i--) {
        const enemy = enemies[i];
        enemy.position.z += enemy.userData.speed;
        enemy.rotation.y += 0.02;
        
        // Lógica de tiro dos inimigos
        const currentTime = Date.now();
        if (currentTime - enemy.userData.lastShot > enemy.userData.shootCooldown) {
            enemyShoot(enemy);
            enemy.userData.lastShot = currentTime;
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
    
    // Atualizar explosões com física melhorada
    for (let i = explosions.length - 1; i >= 0; i--) {
        const explosion = explosions[i];
        let allParticlesDead = true;
        
        for (let j = explosion.length - 1; j >= 0; j--) {
            const particle = explosion[j];
            
            // === FÍSICA AVANÇADA DAS PARTÍCULAS ===
            
            // Aplicar gravidade se a partícula tiver
            if (particle.userData.gravity !== undefined) {
                particle.userData.velocity.y += particle.userData.gravity;
            }
            
            // Mover partícula
            particle.position.add(particle.userData.velocity);
            
            // Aplicar rotação aos fragmentos
            if (particle.userData.rotationSpeed) {
                particle.rotation.x += particle.userData.rotationSpeed.x;
                particle.rotation.y += particle.userData.rotationSpeed.y;
                particle.rotation.z += particle.userData.rotationSpeed.z;
            }
            
            // Aplicar escala dinâmica (para núcleo e anel de choque)
            if (particle.userData.scaleSpeed !== undefined) {
                particle.userData.scale += particle.userData.scaleSpeed * 0.016; // ~60fps
                particle.scale.setScalar(particle.userData.scale);
                
                // Reduzir opacidade conforme cresce (para anel de choque)
                if (particle.userData.scaleSpeed > 5) {
                    particle.material.opacity = particle.userData.life * (1 / particle.userData.scale);
                }
            }
            
            // Diminuir vida da partícula
            particle.userData.life -= particle.userData.decay;
            
            // Atualizar opacidade baseada na vida
            if (!particle.userData.scaleSpeed || particle.userData.scaleSpeed <= 5) {
                particle.material.opacity = particle.userData.life;
            }
            particle.material.transparent = true;
            
            // Efeito de fade para fumaça (crescimento + transparência)
            if (particle.userData.scaleSpeed && particle.userData.scaleSpeed < 3) {
                const smokeScale = 1 + (1 - particle.userData.life) * particle.userData.scaleSpeed;
                particle.scale.setScalar(smokeScale);
                particle.material.opacity = particle.userData.life * 0.6;
            }
            
            // Remover partículas mortas
            if (particle.userData.life <= 0) {
                scene.remove(particle);
                explosion.splice(j, 1);
            } else {
                allParticlesDead = false;
            }
        }
        
        // Remover explosão se todas as partículas morreram
        if (allParticlesDead) {
            explosions.splice(i, 1);
        }
    }
    
    // Animar estrelas melhoradas (piscada e rotação)
    stars.forEach(star => {
        // Rotação básica
        if (star.userData.rotationSpeed) {
            star.rotation.x += star.userData.rotationSpeed;
            star.rotation.y += star.userData.rotationSpeed;
        } else {
            star.rotation.x += 0.001;
            star.rotation.y += 0.001;
        }
        
        // Efeito de piscada (twinkle)
        if (star.userData.twinkleSpeed) {
            star.userData.twinklePhase += star.userData.twinkleSpeed;
            const twinkle = Math.sin(star.userData.twinklePhase) * 0.3 + 0.7;
            star.material.opacity = star.userData.baseOpacity * twinkle;
            
            // Atualizar halo se existir
            if (star.userData.halo) {
                star.userData.halo.material.opacity = 0.2 * twinkle;
            }
        }
    });
    
    // Verificar colisões
    checkCollisions();
    
    // Renderizar
    renderer.render(scene, camera);
}

// Inicializar jogo quando a página carregar
window.addEventListener('load', init);