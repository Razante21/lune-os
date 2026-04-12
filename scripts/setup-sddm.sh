#!/bin/bash
# Lune OS — Configura tema SDDM

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[SDDM]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[SDDM]${NC} $1"; }

THEME_DIR="/usr/share/sddm/themes/lune-os"
SCRIPT_DIR="$(dirname "$0")"

log_info "Instalando tema SDDM do Lune OS..."

# Criar diretório do tema
sudo mkdir -p "$THEME_DIR"

# Copiar arquivos do tema
sudo cp "$SCRIPT_DIR/../installer/sddm-theme/Main.qml"         "$THEME_DIR/"
sudo cp "$SCRIPT_DIR/../installer/sddm-theme/theme.conf"       "$THEME_DIR/"
sudo cp "$SCRIPT_DIR/../installer/sddm-theme/metadata.desktop" "$THEME_DIR/"

# Wallpaper padrão do tema
if [ -f "$HOME/.config/lune/wallpapers/current.jpg" ]; then
    sudo cp "$HOME/.config/lune/wallpapers/current.jpg" "$THEME_DIR/background.jpg"
else
    # Fallback — cria um fundo sólido escuro
    log_info "Wallpaper não encontrado — usando cor sólida como fallback"
fi

# Configurar SDDM para usar o tema Lune
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/lune.conf > /dev/null << 'CONF'
[Theme]
Current=lune-os

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell
CONF

# Habilitar e iniciar SDDM
sudo systemctl enable sddm
log_ok "Tema SDDM instalado e configurado!"
log_info "Reinicie para ver o novo tema de login"
