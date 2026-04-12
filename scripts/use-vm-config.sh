#!/bin/bash
# Lune OS — Ativa config de VM (sem GPU acelerada)

CONFIG="$HOME/.config/hypr"

echo "🖥️  Ativando config Lune OS para VM..."

# Backup do config atual
if [ -f "$CONFIG/hyprland.conf" ]; then
    cp "$CONFIG/hyprland.conf" "$CONFIG/hyprland.conf.bkp"
    echo "✅ Backup criado: hyprland.conf.bkp"
fi

# Ativa config VM
cp "$HOME/lune-os/dotfiles/hypr/hyprland-vm.conf" "$CONFIG/hyprland.conf"

echo ""
echo "✅ Config VM ativado!"
echo ""
echo "Agora roda: Hyprland"
echo ""
echo "Para voltar ao config normal: cp ~/.config/hypr/hyprland.conf.bkp ~/.config/hypr/hyprland.conf"
