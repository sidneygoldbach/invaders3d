// Sistema de Áudio para o jogo Invaders 3D
class AudioSystem {
    constructor() {
        this.audioContext = null;
        this.masterVolume = 0.3;
        this.musicVolume = 0.1;
        this.sfxVolume = 0.4;
        this.backgroundMusic = null;
        this.init();
    }

    init() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            this.startBackgroundMusic();
        } catch (error) {
            console.log('Web Audio API não suportado:', error);
        }
    }

    // Música de fundo ambiente
    startBackgroundMusic() {
        if (!this.audioContext) return;

        const playAmbientTone = () => {
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();
            
            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);
            
            // Tom ambiente espacial
            oscillator.frequency.setValueAtTime(80, this.audioContext.currentTime);
            oscillator.frequency.exponentialRampToValueAtTime(120, this.audioContext.currentTime + 8);
            oscillator.frequency.exponentialRampToValueAtTime(80, this.audioContext.currentTime + 16);
            
            oscillator.type = 'sine';
            
            gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
            gainNode.gain.linearRampToValueAtTime(this.musicVolume, this.audioContext.currentTime + 2);
            gainNode.gain.linearRampToValueAtTime(this.musicVolume * 0.7, this.audioContext.currentTime + 8);
            gainNode.gain.linearRampToValueAtTime(this.musicVolume, this.audioContext.currentTime + 14);
            gainNode.gain.linearRampToValueAtTime(0, this.audioContext.currentTime + 16);
            
            oscillator.start(this.audioContext.currentTime);
            oscillator.stop(this.audioContext.currentTime + 16);
            
            // Repetir a música
            setTimeout(() => {
                if (this.audioContext) {
                    playAmbientTone();
                }
            }, 16000);
        };

        playAmbientTone();
    }

    // Som de tiro do jogador - laser agudo
    playPlayerShoot() {
        if (!this.audioContext) return;

        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);
        
        oscillator.frequency.setValueAtTime(800, this.audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(400, this.audioContext.currentTime + 0.1);
        oscillator.type = 'square';
        
        gainNode.gain.setValueAtTime(this.sfxVolume, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.1);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.1);
    }

    // Som de tiro do inimigo - laser grave
    playEnemyShoot() {
        if (!this.audioContext) return;

        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);
        
        oscillator.frequency.setValueAtTime(200, this.audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(100, this.audioContext.currentTime + 0.15);
        oscillator.type = 'sawtooth';
        
        gainNode.gain.setValueAtTime(this.sfxVolume * 0.8, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.15);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.15);
    }

    // Som quando jogador é atingido - alarme
    playPlayerHit() {
        if (!this.audioContext) return;

        const oscillator1 = this.audioContext.createOscillator();
        const oscillator2 = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();
        
        oscillator1.connect(gainNode);
        oscillator2.connect(gainNode);
        gainNode.connect(this.audioContext.destination);
        
        // Duas frequências para criar um som de alarme
        oscillator1.frequency.setValueAtTime(300, this.audioContext.currentTime);
        oscillator2.frequency.setValueAtTime(500, this.audioContext.currentTime);
        
        oscillator1.type = 'square';
        oscillator2.type = 'square';
        
        // Modulação para criar efeito de alarme
        for (let i = 0; i < 3; i++) {
            const time = this.audioContext.currentTime + (i * 0.1);
            gainNode.gain.setValueAtTime(0, time);
            gainNode.gain.linearRampToValueAtTime(this.sfxVolume, time + 0.03);
            gainNode.gain.linearRampToValueAtTime(0, time + 0.08);
        }
        
        oscillator1.start(this.audioContext.currentTime);
        oscillator2.start(this.audioContext.currentTime);
        oscillator1.stop(this.audioContext.currentTime + 0.3);
        oscillator2.stop(this.audioContext.currentTime + 0.3);
    }

    // Som quando inimigo é atingido - explosão
    playEnemyHit() {
        if (!this.audioContext) return;

        // Ruído branco para simular explosão
        const bufferSize = this.audioContext.sampleRate * 0.2;
        const buffer = this.audioContext.createBuffer(1, bufferSize, this.audioContext.sampleRate);
        const data = buffer.getChannelData(0);
        
        for (let i = 0; i < bufferSize; i++) {
            data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / bufferSize, 2);
        }
        
        const source = this.audioContext.createBufferSource();
        const gainNode = this.audioContext.createGain();
        const filter = this.audioContext.createBiquadFilter();
        
        source.buffer = buffer;
        source.connect(filter);
        filter.connect(gainNode);
        gainNode.connect(this.audioContext.destination);
        
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(1000, this.audioContext.currentTime);
        filter.frequency.exponentialRampToValueAtTime(100, this.audioContext.currentTime + 0.2);
        
        gainNode.gain.setValueAtTime(this.sfxVolume * 0.6, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.2);
        
        source.start(this.audioContext.currentTime);
    }

    // Método para ajustar volumes
    setMasterVolume(volume) {
        this.masterVolume = Math.max(0, Math.min(1, volume));
    }

    setMusicVolume(volume) {
        this.musicVolume = Math.max(0, Math.min(1, volume));
    }

    setSfxVolume(volume) {
        this.sfxVolume = Math.max(0, Math.min(1, volume));
    }

    // Pausar/retomar música
    pauseMusic() {
        if (this.audioContext && this.audioContext.state === 'running') {
            this.audioContext.suspend();
        }
    }

    resumeMusic() {
        if (this.audioContext && this.audioContext.state === 'suspended') {
            this.audioContext.resume();
        }
    }
}

// Instância global do sistema de áudio
const audioSystem = new AudioSystem();