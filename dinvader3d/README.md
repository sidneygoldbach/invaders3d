# D-Invader 3D - Space Invaders em Delphi

Uma versão completa do jogo Space Invaders 3D implementada em Delphi, baseada na versão JavaScript original.

## 📋 Características

### 🎮 **Gameplay**
- Jogador controlável com movimento lateral (A/D ou setas)
- Tiro com barra de espaço
- Sistema de vidas (3 vidas, mudança de cor a cada acerto)
- Inimigos UFO que se movem e atiram
- Aviões que soltam paraquedistas para resgate
- Sistema de pontuação
- Efeitos de explosão

### 🎨 **Gráficos 3D**
- Renderização wireframe 3D personalizada
- Projeção perspectiva
- Campo de estrelas animado
- Objetos 3D: cubos, esferas, cones
- Interface de usuário integrada

### 🔊 **Sistema de Áudio**
- Música de fundo ambiente
- Efeitos sonoros para tiros
- Sons de explosão e acertos
- Controle de volume independente

## 🏗️ **Arquitetura do Projeto**

### **Arquivos Principais:**
- `DInvader3D.dpr` - Arquivo principal do projeto
- `MainForm.pas/.dfm` - Formulário principal e interface
- `GameEngine.pas` - Engine principal do jogo
- `GameObjects.pas` - Classes dos objetos do jogo
- `Renderer3D.pas` - Sistema de renderização 3D
- `AudioSystem.pas` - Sistema de áudio

### **Classes Principais:**

#### **TGameEngine**
- Controla toda a lógica do jogo
- Gerencia colisões e pontuação
- Coordena spawn de inimigos e objetos

#### **TGameObject (e derivadas)**
- `TPlayer` - Jogador controlável
- `TEnemy` - Inimigos UFO
- `TBullet` - Projéteis
- `TAirplane` - Aviões
- `TParachutist` - Paraquedistas
- `TExplosion` - Efeitos de explosão
- `TStar` - Estrelas do campo de fundo

#### **TRenderer3D**
- Renderização wireframe 3D
- Projeção perspectiva
- Desenho de primitivas 3D

#### **TAudioSystem**
- Efeitos sonoros usando Windows API
- Música de fundo em thread separada
- Controle de volume

## 🎯 **Controles**

- **A / Seta Esquerda**: Mover para esquerda
- **D / Seta Direita**: Mover para direita
- **Barra de Espaço**: Atirar
- **ESC**: Sair do jogo

## 🏆 **Sistema de Pontuação**

- **UFO destruído**: 100 pontos
- **Avião destruído**: 200 pontos
- **Paraquedista resgatado**: 50 pontos

## 🎨 **Sistema de Vidas**

O jogador possui 3 vidas e muda de cor conforme recebe danos:
- **Verde**: Estado inicial
- **Azul**: Após primeiro acerto
- **Vermelho**: Após segundo acerto
- **Game Over**: Após terceiro acerto

## 🔧 **Requisitos de Compilação**

### **Delphi/RAD Studio:**
- Delphi 10.3 Rio ou superior
- VCL Application
- Windows 32-bit ou 64-bit

### **Units Necessárias:**
- `Vcl.Forms`
- `Vcl.Graphics`
- `Vcl.Controls`
- `Vcl.ExtCtrls`
- `System.Classes`
- `System.Generics.Collections`
- `Winapi.Windows`
- `Winapi.MMSystem`

## 🚀 **Como Compilar e Executar**

1. **Abrir o Projeto:**
   ```
   Abra o arquivo DInvader3D.dpr no Delphi
   ```

2. **Compilar:**
   ```
   Build > Build DInvader3D
   ou pressione Ctrl+F9
   ```

3. **Executar:**
   ```
   Run > Run
   ou pressione F9
   ```

## 🎮 **Como Jogar**

1. Clique em "Iniciar" para começar o jogo
2. Use A/D para mover o jogador
3. Pressione SPACE para atirar nos UFOs
4. Destrua aviões para fazer paraquedistas aparecerem
5. Colete paraquedistas para pontos extras
6. Evite ser atingido pelos tiros inimigos
7. Sobreviva o máximo possível!

## 🔄 **Diferenças da Versão JavaScript**

### **Melhorias:**
- Interface nativa do Windows
- Renderização 3D otimizada para desktop
- Sistema de áudio usando Windows API
- Controles de teclado nativos
- Performance melhorada

### **Adaptações:**
- Substituição do Three.js por renderização personalizada
- Web Audio API substituída por Windows Beep API
- Canvas HTML substituído por TPanel com OnPaint
- Timer JavaScript substituído por TTimer

## 🐛 **Limitações Conhecidas**

- Sistema de áudio usa apenas tons simples (Windows Beep)
- Renderização 3D é wireframe (sem texturas)
- Sem suporte a joystick (apenas teclado)

## 🔮 **Possíveis Melhorias Futuras**

- Integração com DirectX ou OpenGL
- Sistema de áudio mais avançado (DirectSound)
- Texturas e modelos 3D mais complexos
- Suporte a joystick/gamepad
- Sistema de high scores
- Múltiplas fases/níveis

## 📝 **Licença**

Este projeto é uma adaptação educacional do jogo Space Invaders clássico, implementado em Delphi para fins de aprendizado e demonstração.

---

**Desenvolvido como conversão da versão JavaScript original para Delphi/Pascal**