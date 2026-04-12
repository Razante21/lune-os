#!/bin/bash
# Lune OS — Cheat Sheet Visual
# Segura Super por 1s — mostra todos os atalhos sobrepostos ao desktop

CHEATSHEET_HTML="/tmp/lune-cheatsheet.html"

cat > "$CHEATSHEET_HTML" << 'HTML'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body {
  font-family: 'JetBrains Mono', monospace;
  background: rgba(13,14,20,0.92);
  color: #E8E8F0;
  padding: 32px;
  min-height: 100vh;
}
h1 { color: #C8A8E9; font-size: 22px; margin-bottom: 24px; text-align: center; }
.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
.section h2 {
  color: #7EB8F7;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 10px;
  padding-bottom: 6px;
  border-bottom: 1px solid rgba(200,168,233,0.2);
}
.row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 5px 0;
  font-size: 12px;
  border-bottom: 1px solid rgba(255,255,255,0.04);
}
.row:last-child { border: none; }
.action { color: #A0A0B0; }
.key {
  background: rgba(200,168,233,0.12);
  border: 1px solid rgba(200,168,233,0.3);
  border-radius: 5px;
  padding: 2px 8px;
  color: #C8A8E9;
  font-size: 11px;
  white-space: nowrap;
}
.footer {
  text-align: center;
  margin-top: 24px;
  color: #A0A0B060;
  font-size: 11px;
}
</style>
</head>
<body>
<h1>🌙 Lune OS — Atalhos</h1>
<div class="grid">
  <div class="section">
    <h2>Apps</h2>
    <div class="row"><span class="action">Launcher</span><span class="key">Super + Space</span></div>
    <div class="row"><span class="action">Terminal</span><span class="key">Super + T</span></div>
    <div class="row"><span class="action">Arquivos</span><span class="key">Super + E</span></div>
    <div class="row"><span class="action">Assistente IA</span><span class="key">Super + A</span></div>
    <div class="row"><span class="action">Configurações</span><span class="key">Super + I</span></div>
    <div class="row"><span class="action">Loja de Apps</span><span class="key">Super + S</span></div>
    <div class="row"><span class="action">Ajuda</span><span class="key">Super + F1</span></div>
    <div class="row"><span class="action">Calculadora</span><span class="key">Super + C</span></div>
    <div class="row"><span class="action">Wallpaper</span><span class="key">Super + W</span></div>
  </div>
  <div class="section">
    <h2>Janelas</h2>
    <div class="row"><span class="action">Fechar</span><span class="key">Super + Q</span></div>
    <div class="row"><span class="action">Minimizar</span><span class="key">Super + N</span></div>
    <div class="row"><span class="action">Maximizar</span><span class="key">Super + ↑</span></div>
    <div class="row"><span class="action">Flutuar</span><span class="key">Super + V</span></div>
    <div class="row"><span class="action">Mover foco</span><span class="key">Super + ←→↑↓</span></div>
    <div class="row"><span class="action">Redimensionar</span><span class="key">Super+Shift+←→</span></div>
    <div class="row"><span class="action">Tela cheia</span><span class="key">Super + F11</span></div>
    <div class="row"><span class="action">Overview</span><span class="key">Super + Tab</span></div>
    <div class="row"><span class="action">Modo Foco</span><span class="key">Super + F</span></div>
  </div>
  <div class="section">
    <h2>Workspaces</h2>
    <div class="row"><span class="action">Workspace 1-5</span><span class="key">Super + 1-5</span></div>
    <div class="row"><span class="action">Anterior</span><span class="key">Super + [</span></div>
    <div class="row"><span class="action">Próximo</span><span class="key">Super + ]</span></div>
    <div class="row"><span class="action">Mover janela</span><span class="key">Super+Shift+1-5</span></div>
    <h2 style="margin-top:16px">Sistema</h2>
    <div class="row"><span class="action">Bloquear</span><span class="key">Super + L</span></div>
    <div class="row"><span class="action">Menu energia</span><span class="key">Super + Esc</span></div>
    <div class="row"><span class="action">Captura área</span><span class="key">Super+Shift+S</span></div>
    <div class="row"><span class="action">Recarregar</span><span class="key">Super+Shift+R</span></div>
    <div class="row"><span class="action">Atalhos</span><span class="key">Segurar Super</span></div>
  </div>
</div>
<div class="footer">Pressione qualquer tecla para fechar</div>
<script>
document.addEventListener('keydown', () => window.close());
document.addEventListener('click', () => window.close());
</script>
</body>
</html>
HTML

# Abrir como overlay
if command -v google-chrome-stable &>/dev/null; then
    google-chrome-stable \
        --app="file://$CHEATSHEET_HTML" \
        --window-size=900,600 \
        --window-position=200,150 \
        --no-default-browser-check &
elif command -v firefox &>/dev/null; then
    firefox --new-window "file://$CHEATSHEET_HTML" &
fi
