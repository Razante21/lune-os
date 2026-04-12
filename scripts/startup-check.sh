#!/bin/bash
# Lune OS — Verificação silenciosa no startup
# Roda 30s após o login — verifica atualizações e saúde do sistema

sleep 5

# Verificar atualizações disponíveis
UPDATES=$(checkupdates 2>/dev/null | wc -l || echo "0")

if [ "$UPDATES" -gt 0 ]; then
    notify-send "🌙 Lune OS — Atualizações disponíveis" \
        "$UPDATES pacotes podem ser atualizados. O sistema será atualizado automaticamente às 3h." \
        --expire-time=8000 \
        --icon=software-update-available
fi

# Verificar se é primeiro boot
WELCOME_DONE="$HOME/.config/lune/.welcome-done"
if [ ! -f "$WELCOME_DONE" ]; then
    sleep 3
    bash ~/.config/hypr/scripts/../../scripts/lune-welcome.sh &
fi

# Verificar espaço em disco
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 85 ]; then
    notify-send "⚠️ Lune OS — Disco quase cheio" \
        "Uso de disco: ${DISK_USAGE}%. Considere liberar espaço." \
        --icon=drive-harddisk \
        --urgency=normal
fi
