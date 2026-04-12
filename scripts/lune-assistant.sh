#!/bin/bash
# Lune OS — Lune Assistant
# Sidebar com IA (Gemini API) integrada ao desktop
# Super+A para abrir/fechar

ASSISTANT_PID_FILE="/tmp/lune-assistant.pid"
ASSISTANT_PORT=7891

# Verificar se já tá rodando
if [ -f "$ASSISTANT_PID_FILE" ]; then
    PID=$(cat "$ASSISTANT_PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        # Está rodando — fechar
        kill "$PID"
        rm -f "$ASSISTANT_PID_FILE"
        exit 0
    fi
fi

# Verificar se tem API key configurada
GEMINI_KEY_FILE="$HOME/.config/lune/gemini-api-key"

if [ ! -f "$GEMINI_KEY_FILE" ]; then
    # Pedir API key na primeira vez
    API_KEY=$(rofi -dmenu -p "🌙 Lune Assistant — Cole sua Gemini API key:" \
        -theme ~/.config/rofi/lune.rasi \
        -password)

    if [ -z "$API_KEY" ]; then
        notify-send "🌙 Lune Assistant" "API key necessária. Obtenha em: aistudio.google.com"
        exit 1
    fi

    mkdir -p "$HOME/.config/lune"
    echo "$API_KEY" > "$GEMINI_KEY_FILE"
    chmod 600 "$GEMINI_KEY_FILE"
fi

GEMINI_API_KEY=$(cat "$GEMINI_KEY_FILE")

# Criar interface HTML do assistente
ASSISTANT_HTML="/tmp/lune-assistant.html"

cat > "$ASSISTANT_HTML" << 'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Lune Assistant</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: 'Inter', sans-serif;
    background: rgba(13, 14, 20, 0.95);
    color: #E8E8F0;
    height: 100vh;
    display: flex;
    flex-direction: column;
  }
  header {
    padding: 16px 20px;
    border-bottom: 1px solid rgba(200,168,233,0.2);
    display: flex;
    align-items: center;
    gap: 10px;
  }
  header span { font-size: 20px; }
  header h1 { font-size: 16px; color: #C8A8E9; font-weight: 600; }
  header p { font-size: 11px; color: #A0A0B0; }
  #chat {
    flex: 1;
    overflow-y: auto;
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  .msg {
    max-width: 85%;
    padding: 10px 14px;
    border-radius: 12px;
    font-size: 13px;
    line-height: 1.5;
  }
  .msg.user {
    background: rgba(200,168,233,0.15);
    border: 1px solid rgba(200,168,233,0.3);
    align-self: flex-end;
  }
  .msg.ai {
    background: rgba(26,27,38,0.8);
    border: 1px solid rgba(46,47,62,0.8);
    align-self: flex-start;
  }
  .msg.ai .label { color: #C8A8E9; font-size: 11px; margin-bottom: 4px; }
  footer {
    padding: 12px 16px;
    border-top: 1px solid rgba(200,168,233,0.2);
    display: flex;
    gap: 8px;
  }
  textarea {
    flex: 1;
    background: rgba(46,47,62,0.6);
    border: 1px solid rgba(200,168,233,0.2);
    border-radius: 10px;
    color: #E8E8F0;
    padding: 10px 12px;
    font-size: 13px;
    font-family: inherit;
    resize: none;
    height: 44px;
    outline: none;
  }
  textarea:focus { border-color: rgba(200,168,233,0.6); }
  button {
    background: #C8A8E9;
    border: none;
    border-radius: 10px;
    color: #0D0E14;
    padding: 0 16px;
    font-weight: 600;
    cursor: pointer;
    font-size: 13px;
  }
  button:hover { background: #9B7FD4; }
</style>
</head>
<body>
<header>
  <span>🌙</span>
  <div>
    <h1>Lune Assistant</h1>
    <p>Powered by Gemini</p>
  </div>
</header>
<div id="chat">
  <div class="msg ai">
    <div class="label">Lune Assistant</div>
    Olá! Sou o Lune Assistant. Como posso ajudar você hoje?
  </div>
</div>
<footer>
  <textarea id="input" placeholder="Digite sua mensagem..." onkeydown="handleKey(event)"></textarea>
  <button onclick="sendMessage()">Enviar</button>
</footer>
<script>
const API_KEY = localStorage.getItem('gemini_key') || prompt('Cole sua Gemini API key:');
if (API_KEY) localStorage.setItem('gemini_key', API_KEY);

const chat = document.getElementById('chat');
const input = document.getElementById('input');
let history = [];

function handleKey(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
}

async function sendMessage() {
  const text = input.value.trim();
  if (!text) return;

  addMessage(text, 'user');
  input.value = '';
  history.push({ role: 'user', parts: [{ text }] });

  const loading = addMessage('...', 'ai');

  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: history,
          systemInstruction: {
            parts: [{ text: 'Você é o Lune Assistant, o assistente de IA integrado ao Lune OS. Responda de forma concisa e útil em português. Você pode ajudar com: atalhos do sistema, configurações, apps, problemas técnicos e uso geral do Lune OS.' }]
          }
        })
      }
    );
    const data = await res.json();
    const reply = data.candidates?.[0]?.content?.parts?.[0]?.text || 'Erro ao obter resposta.';
    loading.innerHTML = `<div class="label">Lune Assistant</div>${reply}`;
    history.push({ role: 'model', parts: [{ text: reply }] });
  } catch(e) {
    loading.innerHTML = '<div class="label">Lune Assistant</div>Erro de conexão.';
  }

  chat.scrollTop = chat.scrollHeight;
}

function addMessage(text, role) {
  const div = document.createElement('div');
  div.className = `msg ${role}`;
  if (role === 'ai') div.innerHTML = `<div class="label">Lune Assistant</div>${text}`;
  else div.textContent = text;
  chat.appendChild(div);
  chat.scrollTop = chat.scrollHeight;
  return div;
}
</script>
</body>
</html>
HTML

# Abrir no browser em modo app (sidebar)
if command -v google-chrome-stable &>/dev/null; then
    google-chrome-stable \
        --app="file://$ASSISTANT_HTML" \
        --window-size=380,700 \
        --window-position=1540,100 \
        --no-default-browser-check \
        --no-first-run &
    echo $! > "$ASSISTANT_PID_FILE"
elif command -v firefox &>/dev/null; then
    firefox --new-window "file://$ASSISTANT_HTML" &
    echo $! > "$ASSISTANT_PID_FILE"
else
    notify-send "🌙 Lune Assistant" "Nenhum browser encontrado. Instale o Chrome ou Firefox."
fi
