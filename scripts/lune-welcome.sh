#!/bin/bash
# Lune OS — Lune Welcome
# Primeiro boot — personalização guiada
# Roda automaticamente na primeira vez que o usuário loga

WELCOME_DONE="$HOME/.config/lune/.welcome-done"

# Se já rodou antes, não roda de novo
[ -f "$WELCOME_DONE" ] && exit 0

# Função de dialog com rofi
ask() {
    local prompt="$1"
    shift
    printf '%s\n' "$@" | rofi -dmenu -p "$prompt" -theme ~/.config/rofi/lune.rasi
}

# ── Tela 1 — Boas-vindas ────────────────────────────────────
notify-send "🌙 Bem-vindo ao Lune OS!" \
    "Vamos personalizar seu sistema em 4 perguntas rápidas." \
    --expire-time=4000

sleep 2

# ── Tela 2 — Idioma ──────────────────────────────────────────
LANG_CHOICE=$(ask "🌍 Qual idioma você prefere?" \
    "Português Brasileiro" \
    "English")

if [ "$LANG_CHOICE" = "English" ]; then
    # Mudar locale para inglês
    echo "LANG=en_US.UTF-8" > ~/.config/locale.conf
fi

# ── Tela 3 — Tema visual ─────────────────────────────────────
THEME_CHOICE=$(ask "🎨 Escolha seu tema visual:" \
    "🌙 Lune Dark (padrão)" \
    "🌸 Lune Light" \
    "🌿 Lune Aurora (verde)" \
    "🌅 Lune Sunset (laranja)" \
    "🌊 Lune Ocean (azul)" \
    "⬛ Lune Monochrome")

# Aplicar tema escolhido
case "$THEME_CHOICE" in
    *"Light"*)    THEME="lune-light" ;;
    *"Aurora"*)   THEME="lune-aurora" ;;
    *"Sunset"*)   THEME="lune-sunset" ;;
    *"Ocean"*)    THEME="lune-ocean" ;;
    *"Mono"*)     THEME="lune-monochrome" ;;
    *)            THEME="lune-dark" ;;
esac

# ── Tela 4 — Layout do teclado ───────────────────────────────
KB_CHOICE=$(ask "⌨️  Qual é seu layout de teclado?" \
    "🇧🇷 Português Brasileiro (ABNT2)" \
    "🇺🇸 Inglês (US QWERTY)" \
    "🇵🇹 Português (ISO)")

case "$KB_CHOICE" in
    *"ABNT2"*) KB="br" ;;
    *"ISO"*)   KB="pt" ;;
    *)         KB="us" ;;
esac

# Aplicar layout
hyprctl keyword input:kb_layout "$KB" 2>/dev/null || true

# ── Tela 5 — Dock ou barra ───────────────────────────────────
DOCK_CHOICE=$(ask "🖥️  Como você prefere a barra de tarefas?" \
    "🍎 Dock (estilo macOS)" \
    "🪟 Barra inferior (estilo Windows)")

# ── Finalização ──────────────────────────────────────────────
mkdir -p "$HOME/.config/lune"

# Salvar preferências
cat > "$HOME/.config/lune/preferences.conf" << PREFS
THEME=$THEME
KB_LAYOUT=$KB
DOCK_STYLE=$DOCK_CHOICE
LANG=$LANG_CHOICE
PREFS

# Marcar como concluído
touch "$WELCOME_DONE"

notify-send "✅ Lune OS configurado!" \
    "Bem-vindo ao seu novo sistema. Use Super+F1 para ver todos os atalhos." \
    --expire-time=6000

