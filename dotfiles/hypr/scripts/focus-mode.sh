#!/bin/bash
# Lune OS — Modo Foco
# Super+F: remove distrações visuais para concentração total

STATE_FILE="/tmp/lune-focus-mode"

enable_focus() {
    touch "$STATE_FILE"
    # Esconder Waybar
    pkill -SIGUSR1 waybar 2>/dev/null || true
    # Aumentar gaps
    hyprctl keyword general:gaps_in 24
    hyprctl keyword general:gaps_out 32
    # Aumentar blur
    hyprctl keyword decoration:blur:passes 5
    hyprctl keyword decoration:blur:size 12
    # Silenciar notificações
    swaync-client --dnd-on 2>/dev/null || true
    # Notificação discreta
    notify-send "🌙 Modo Foco" "Ativado. Pressione Super+F para sair." \
        --expire-time=2000 2>/dev/null || true
}

disable_focus() {
    rm -f "$STATE_FILE"
    # Mostrar Waybar
    pkill -SIGUSR1 waybar 2>/dev/null || true
    # Restaurar gaps
    hyprctl keyword general:gaps_in 10
    hyprctl keyword general:gaps_out 14
    # Restaurar blur
    hyprctl keyword decoration:blur:passes 3
    hyprctl keyword decoration:blur:size 8
    # Reativar notificações
    swaync-client --dnd-off 2>/dev/null || true
}

# Toggle
if [ -f "$STATE_FILE" ]; then
    disable_focus
else
    enable_focus
fi
