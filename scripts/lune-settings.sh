#!/bin/bash
# Lune OS — Painel de Configurações
# Abre uma interface web local para configurar o sistema

SETTINGS_HTML="/tmp/lune-settings.html"
PORT=7892

cat > "$SETTINGS_HTML" << 'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Lune OS — Configurações</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  
  :root {
    --bg: #0D0E14;
    --bg-alt: #1A1B26;
    --surface: #2E2F3E;
    --fg: #E8E8F0;
    --fg-dim: #A0A0B0;
    --primary: #C8A8E9;
    --secondary: #7EB8F7;
    --error: #EB5757;
    --success: #6FD08C;
  }

  body {
    font-family: 'Inter', -apple-system, sans-serif;
    background: var(--bg);
    color: var(--fg);
    min-height: 100vh;
    display: flex;
  }

  /* Sidebar */
  .sidebar {
    width: 220px;
    background: var(--bg-alt);
    border-right: 1px solid rgba(200,168,233,0.1);
    padding: 24px 0;
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex-shrink: 0;
  }

  .sidebar-logo {
    padding: 0 20px 20px;
    border-bottom: 1px solid rgba(200,168,233,0.1);
    margin-bottom: 8px;
  }

  .sidebar-logo h1 {
    color: var(--primary);
    font-size: 18px;
    font-weight: 700;
  }

  .sidebar-logo p {
    color: var(--fg-dim);
    font-size: 11px;
    margin-top: 2px;
  }

  .nav-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 20px;
    color: var(--fg-dim);
    cursor: pointer;
    border-radius: 0;
    font-size: 13px;
    transition: all 0.15s;
    border-left: 3px solid transparent;
  }

  .nav-item:hover { background: rgba(200,168,233,0.06); color: var(--fg); }
  .nav-item.active {
    background: rgba(200,168,233,0.1);
    color: var(--primary);
    border-left-color: var(--primary);
  }

  .nav-icon { font-size: 16px; width: 20px; text-align: center; }

  /* Main */
  .main {
    flex: 1;
    padding: 32px;
    overflow-y: auto;
  }

  .page { display: none; }
  .page.active { display: block; }

  h2 {
    font-size: 20px;
    color: var(--fg);
    margin-bottom: 8px;
  }

  .page-desc {
    color: var(--fg-dim);
    font-size: 13px;
    margin-bottom: 28px;
  }

  /* Cards */
  .card {
    background: var(--bg-alt);
    border: 1px solid rgba(200,168,233,0.1);
    border-radius: 14px;
    padding: 20px;
    margin-bottom: 16px;
  }

  .card h3 {
    font-size: 14px;
    color: var(--fg);
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  /* Temas */
  .themes-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
  }

  .theme-card {
    border-radius: 12px;
    overflow: hidden;
    cursor: pointer;
    border: 2px solid transparent;
    transition: all 0.2s;
  }

  .theme-card:hover { transform: translateY(-2px); }
  .theme-card.active { border-color: var(--primary); }

  .theme-preview {
    height: 70px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
  }

  .theme-info {
    padding: 8px 10px;
    background: var(--surface);
  }

  .theme-info h4 { font-size: 12px; color: var(--fg); }
  .theme-info p  { font-size: 11px; color: var(--fg-dim); margin-top: 2px; }

  /* Toggle */
  .setting-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 0;
    border-bottom: 1px solid rgba(255,255,255,0.05);
  }

  .setting-row:last-child { border: none; }

  .setting-label h4 { font-size: 13px; color: var(--fg); }
  .setting-label p  { font-size: 11px; color: var(--fg-dim); margin-top: 3px; }

  .toggle {
    width: 42px;
    height: 24px;
    background: var(--surface);
    border-radius: 12px;
    cursor: pointer;
    position: relative;
    transition: background 0.2s;
    border: none;
    outline: none;
  }

  .toggle.on { background: var(--primary); }

  .toggle::after {
    content: '';
    position: absolute;
    width: 18px;
    height: 18px;
    background: white;
    border-radius: 50%;
    top: 3px;
    left: 3px;
    transition: left 0.2s;
  }

  .toggle.on::after { left: 21px; }

  /* Select */
  select {
    background: var(--surface);
    border: 1px solid rgba(200,168,233,0.2);
    border-radius: 8px;
    color: var(--fg);
    padding: 6px 10px;
    font-size: 12px;
    outline: none;
    cursor: pointer;
  }

  /* Botão */
  .btn {
    background: var(--primary);
    border: none;
    border-radius: 10px;
    color: var(--bg);
    padding: 10px 20px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
  }

  .btn:hover { background: var(--secondary); }

  .btn-outline {
    background: transparent;
    border: 1px solid rgba(200,168,233,0.3);
    color: var(--primary);
  }

  .btn-outline:hover { background: rgba(200,168,233,0.1); }

  .btn-danger {
    background: var(--error);
    color: white;
  }

  /* Sobre */
  .about-logo {
    text-align: center;
    padding: 32px 0;
  }

  .about-logo .emoji { font-size: 64px; }
  .about-logo h1 { color: var(--primary); font-size: 28px; margin-top: 12px; }
  .about-logo p { color: var(--fg-dim); font-size: 13px; margin-top: 4px; }

  .version-badge {
    display: inline-block;
    background: rgba(200,168,233,0.15);
    border: 1px solid rgba(200,168,233,0.3);
    border-radius: 20px;
    padding: 4px 14px;
    font-size: 12px;
    color: var(--primary);
    margin-top: 8px;
  }

  .info-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-top: 20px;
  }

  .info-item {
    background: var(--surface);
    border-radius: 10px;
    padding: 14px;
  }

  .info-item label { font-size: 11px; color: var(--fg-dim); }
  .info-item p { font-size: 14px; color: var(--fg); margin-top: 4px; font-weight: 500; }
</style>
</head>
<body>

<nav class="sidebar">
  <div class="sidebar-logo">
    <h1>🌙 Lune OS</h1>
    <p>Your world, just lighter.</p>
  </div>

  <div class="nav-item active" onclick="showPage('aparencia')">
    <span class="nav-icon">🎨</span> Aparência
  </div>
  <div class="nav-item" onclick="showPage('teclado')">
    <span class="nav-icon">⌨️</span> Teclado
  </div>
  <div class="nav-item" onclick="showPage('energia')">
    <span class="nav-icon">⚡</span> Energia
  </div>
  <div class="nav-item" onclick="showPage('privacidade')">
    <span class="nav-icon">🔒</span> Privacidade
  </div>
  <div class="nav-item" onclick="showPage('apps')">
    <span class="nav-icon">📦</span> Aplicativos
  </div>
  <div class="nav-item" onclick="showPage('sobre')">
    <span class="nav-icon">ℹ️</span> Sobre
  </div>
</nav>

<main class="main">

  <!-- APARÊNCIA -->
  <div id="page-aparencia" class="page active">
    <h2>Aparência</h2>
    <p class="page-desc">Personalize o visual do seu Lune OS</p>

    <div class="card">
      <h3>🎨 Tema</h3>
      <div class="themes-grid">
        <div class="theme-card active" onclick="selectTheme('lune-dark', this)">
          <div class="theme-preview" style="background:linear-gradient(135deg,#0D0E14,#1A1B26)">🌙</div>
          <div class="theme-info"><h4>Lune Dark</h4><p>Padrão</p></div>
        </div>
        <div class="theme-card" onclick="selectTheme('lune-light', this)">
          <div class="theme-preview" style="background:linear-gradient(135deg,#F5F5FA,#E8E8F5)">🌸</div>
          <div class="theme-info"><h4>Lune Light</h4><p>Claro</p></div>
        </div>
        <div class="theme-card" onclick="selectTheme('lune-aurora', this)">
          <div class="theme-preview" style="background:linear-gradient(135deg,#0D1614,#1A2620)">🌿</div>
          <div class="theme-info"><h4>Lune Aurora</h4><p>Verde</p></div>
        </div>
        <div class="theme-card" onclick="selectTheme('lune-sunset', this)">
          <div class="theme-preview" style="background:linear-gradient(135deg,#140E0D,#261A18)">🌅</div>
          <div class="theme-info"><h4>Lune Sunset</h4><p>Laranja</p></div>
        </div>
        <div class="theme-card" onclick="selectTheme('lune-ocean', this)">
          <div class="theme-preview" style="background:linear-gradient(135deg,#0A0E14,#141E2A)">🌊</div>
          <div class="theme-info"><h4>Lune Ocean</h4><p>Azul</p></div>
        </div>
        <div class="theme-card" onclick="selectTheme('lune-monochrome', this)">
          <div class="theme-preview" style="background:linear-gradient(135deg,#0A0A0A,#141414)">⬛</div>
          <div class="theme-info"><h4>Monochrome</h4><p>P&B</p></div>
        </div>
      </div>
    </div>

    <div class="card">
      <h3>✨ Efeitos</h3>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Animações</h4>
          <p>Transições suaves de janelas e workspaces</p>
        </div>
        <button class="toggle on" onclick="this.classList.toggle('on')"></button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Blur (desfoque)</h4>
          <p>Efeito glassmorphism na Waybar e Rofi</p>
        </div>
        <button class="toggle on" onclick="this.classList.toggle('on')"></button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Bordas animadas</h4>
          <p>Gradiente girando nas bordas da janela ativa</p>
        </div>
        <button class="toggle on" onclick="this.classList.toggle('on')"></button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Sombras</h4>
          <p>Sombras suaves nas janelas</p>
        </div>
        <button class="toggle on" onclick="this.classList.toggle('on')"></button>
      </div>
    </div>

    <div class="card">
      <h3>🖥️ Layout</h3>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Layout de janelas</h4>
          <p>Como as janelas são organizadas</p>
        </div>
        <select>
          <option>Dwindle (padrão)</option>
          <option>Master</option>
        </select>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Gaps entre janelas</h4>
          <p>Espaçamento interno</p>
        </div>
        <select>
          <option>10px (padrão)</option>
          <option>6px (compacto)</option>
          <option>16px (espaçoso)</option>
          <option>0px (sem gap)</option>
        </select>
      </div>
    </div>
  </div>

  <!-- TECLADO -->
  <div id="page-teclado" class="page">
    <h2>Teclado</h2>
    <p class="page-desc">Configure o layout e atalhos do teclado</p>

    <div class="card">
      <h3>⌨️ Layout</h3>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Layout do teclado</h4>
          <p>Mapa de teclas do sistema</p>
        </div>
        <select>
          <option>🇧🇷 Português Brasileiro (ABNT2)</option>
          <option>🇺🇸 Inglês (US QWERTY)</option>
          <option>🇵🇹 Português (ISO)</option>
        </select>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Tecla modificadora (Super)</h4>
          <p>Tecla base para todos os atalhos</p>
        </div>
        <select>
          <option>Super (Windows)</option>
          <option>Alt</option>
        </select>
      </div>
    </div>

    <div class="card">
      <h3>⚡ Atalhos rápidos</h3>
      <div class="setting-row">
        <div class="setting-label"><h4>Terminal</h4><p>Abrir terminal</p></div>
        <span style="color:var(--primary);font-size:12px">Super + T</span>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Launcher</h4><p>Abrir launcher de apps</p></div>
        <span style="color:var(--primary);font-size:12px">Super + Espaço</span>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Fechar janela</h4><p>Fechar janela ativa</p></div>
        <span style="color:var(--primary);font-size:12px">Super + Q</span>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Bloquear tela</h4><p>Bloquear sessão</p></div>
        <span style="color:var(--primary);font-size:12px">Super + L</span>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Ver todos atalhos</h4></div>
        <button class="btn btn-outline" style="font-size:11px;padding:6px 12px">Super + F1</button>
      </div>
    </div>
  </div>

  <!-- ENERGIA -->
  <div id="page-energia" class="page">
    <h2>Energia</h2>
    <p class="page-desc">Configurações de energia e suspensão</p>

    <div class="card">
      <h3>⚡ Economia de energia</h3>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Reduzir brilho após inatividade</h4>
          <p>Dimming automático da tela</p>
        </div>
        <select>
          <option>5 minutos</option>
          <option>2 minutos</option>
          <option>10 minutos</option>
          <option>Nunca</option>
        </select>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Bloquear tela após inatividade</h4>
          <p>Hyprlock automático</p>
        </div>
        <select>
          <option>10 minutos</option>
          <option>5 minutos</option>
          <option>15 minutos</option>
          <option>30 minutos</option>
          <option>Nunca</option>
        </select>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Desligar monitores</h4>
          <p>DPMS automático</p>
        </div>
        <select>
          <option>12 minutos</option>
          <option>5 minutos</option>
          <option>20 minutos</option>
          <option>Nunca</option>
        </select>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Suspender sistema</h4>
          <p>Suspensão automática</p>
        </div>
        <select>
          <option>30 minutos</option>
          <option>15 minutos</option>
          <option>1 hora</option>
          <option>Nunca</option>
        </select>
      </div>
    </div>
  </div>

  <!-- PRIVACIDADE -->
  <div id="page-privacidade" class="page">
    <h2>Privacidade</h2>
    <p class="page-desc">Controle o que o sistema coleta e compartilha</p>

    <div class="card">
      <h3>🔒 Privacidade</h3>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Histórico de área de transferência</h4>
          <p>Salvar histórico do clipboard (cliphist)</p>
        </div>
        <button class="toggle on" onclick="this.classList.toggle('on')"></button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Telemetria</h4>
          <p>Enviar dados anônimos de uso</p>
        </div>
        <button class="toggle" onclick="this.classList.toggle('on')"></button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Histórico de apps recentes</h4>
          <p>Salvar apps acessados recentemente</p>
        </div>
        <button class="toggle on" onclick="this.classList.toggle('on')"></button>
      </div>
    </div>

    <div class="card">
      <h3>🛡️ Segurança</h3>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Bloquear com senha</h4>
          <p>Exigir senha para desbloquear</p>
        </div>
        <button class="toggle on" onclick="this.classList.toggle('on')"></button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Firewall (UFW)</h4>
          <p>Ativar firewall básico</p>
        </div>
        <button class="toggle" onclick="this.classList.toggle('on')"></button>
      </div>
    </div>
  </div>

  <!-- APPS -->
  <div id="page-apps" class="page">
    <h2>Aplicativos</h2>
    <p class="page-desc">Instale ferramentas e configure apps padrão</p>

    <div class="card">
      <h3>📦 Apps padrão</h3>
      <div class="setting-row">
        <div class="setting-label"><h4>Navegador</h4></div>
        <select>
          <option>Firefox</option>
          <option>Google Chrome</option>
          <option>Brave</option>
        </select>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Terminal</h4></div>
        <select>
          <option>Kitty (padrão)</option>
          <option>Alacritty</option>
          <option>Foot</option>
        </select>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Editor de texto</h4></div>
        <select>
          <option>VS Code</option>
          <option>Neovim</option>
          <option>Gedit</option>
        </select>
      </div>
    </div>

    <div class="card">
      <h3>🧰 Ferramentas extras</h3>
      <div class="setting-row">
        <div class="setting-label">
          <h4>LinuxToys</h4>
          <p>Canivete suíço do Linux — do PsyGreg</p>
        </div>
        <button class="btn btn-outline" style="font-size:11px;padding:6px 14px">Instalar</button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Wine + Binfmt</h4>
          <p>Executar apps .exe do Windows</p>
        </div>
        <button class="btn btn-outline" style="font-size:11px;padding:6px 14px">Configurar</button>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <h4>Flatpak + Flathub</h4>
          <p>Loja de apps universal</p>
        </div>
        <button class="btn btn-outline" style="font-size:11px;padding:6px 14px">Ativar</button>
      </div>
    </div>
  </div>

  <!-- SOBRE -->
  <div id="page-sobre" class="page">
    <div class="about-logo">
      <div class="emoji">🌙</div>
      <h1>Lune OS</h1>
      <p>Your world, just lighter.</p>
      <span class="version-badge">v0.1.0 — Beta</span>
    </div>

    <div class="card">
      <div class="info-grid">
        <div class="info-item">
          <label>Base</label>
          <p>CachyOS / Arch Linux</p>
        </div>
        <div class="info-item">
          <label>Compositor</label>
          <p>Hyprland 0.54</p>
        </div>
        <div class="info-item">
          <label>Kernel</label>
          <p>Linux (CachyOS-bore)</p>
        </div>
        <div class="info-item">
          <label>Pacotes</label>
          <p>pacman + AUR</p>
        </div>
      </div>
    </div>

    <div class="card">
      <h3>🔗 Links</h3>
      <div class="setting-row">
        <div class="setting-label"><h4>Repositório GitHub</h4></div>
        <button class="btn btn-outline" style="font-size:11px;padding:6px 14px"
          onclick="window.open('https://github.com/Razante21/lune-os')">Abrir</button>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Documentação</h4></div>
        <button class="btn btn-outline" style="font-size:11px;padding:6px 14px">Wiki</button>
      </div>
      <div class="setting-row">
        <div class="setting-label"><h4>Reportar bug</h4></div>
        <button class="btn btn-outline" style="font-size:11px;padding:6px 14px"
          onclick="window.open('https://github.com/Razante21/lune-os/issues')">Issues</button>
      </div>
    </div>
  </div>

</main>

<script>
function showPage(name) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.getElementById('page-' + name).classList.add('active');
  event.currentTarget.classList.add('active');
}

function selectTheme(theme, el) {
  document.querySelectorAll('.theme-card').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
  console.log('Tema selecionado:', theme);
  // Aqui chamaria: fetch('/apply-theme?theme=' + theme)
}
</script>

</body>
</html>
HTML

# Abrir no browser como app
if command -v google-chrome-stable &>/dev/null; then
    google-chrome-stable \
        --app="file://$SETTINGS_HTML" \
        --window-size=860,620 \
        --window-position=200,100 \
        --no-default-browser-check &
elif command -v firefox &>/dev/null; then
    firefox --new-window "file://$SETTINGS_HTML" &
else
    notify-send "🌙 Lune Settings" "Nenhum browser encontrado!"
fi
