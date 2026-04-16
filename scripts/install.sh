#!/bin/bash
# Lune OS — Script Principal de Instalação
# Detecta o ambiente desktop e aplica o tema Lune correspondente
# Versão: 0.2.0

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
  echo -e "${PURPLE}"
  echo "  ██╗     ██╗   ██╗███╗   ██╗███████╗"
  echo "  ██║     ██║   ██║████╗  ██║██╔════╝"
  echo "  ██║     ██║   ██║██╔██╗ ██║█████╗  "
  echo "  ██║     ██║   ██║██║╚██╗██║██╔══╝  "
  echo "  ███████╗╚██████╔╝██║ ╚████║███████╗"
  echo "  ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝"
  echo -e "${CYAN}         Your world, just lighter.${NC}"
  echo ""
}

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_error() { echo -e "${RED}[ERRO]${NC} $1"; exit 1; }
log_step()  { echo -e "\n${PURPLE}━━━ $1 ━━━${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ── Detectar ambiente desktop ────────────────────────────────
detect_desktop() {
  log_step "Detectando ambiente desktop"

  # Verificar pela sessão atual
  if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    DESKTOP=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')
  elif [ -n "$DESKTOP_SESSION" ]; then
    DESKTOP=$(echo "$DESKTOP_SESSION" | tr '[:upper:]' '[:lower:]')
  else
    DESKTOP="unknown"
  fi

  # Verificar pacotes instalados como fallback
  if [[ "$DESKTOP" == "unknown" ]]; then
    if command -v plasmashell &>/dev/null; then
      DESKTOP="kde"
    elif command -v gnome-shell &>/dev/null; then
      DESKTOP="gnome"
    elif command -v hyprctl &>/dev/null; then
      DESKTOP="hyprland"
    fi
  fi

  # Normalizar nome
  case "$DESKTOP" in
    *kde*|*plasma*) DESKTOP_NAME="KDE Plasma" ;;
    *gnome*)        DESKTOP_NAME="GNOME" ;;
    *hyprland*)     DESKTOP_NAME="Hyprland" ;;
    *)              DESKTOP_NAME="Desconhecido" ;;
  esac

  log_ok "Ambiente detectado: $DESKTOP_NAME"
}

# ── Perguntar se quer mudar o desktop ───────────────────────
choose_desktop() {
  echo ""
  echo -e "${CYAN}Qual ambiente desktop você quer usar com o Lune OS?${NC}"
  echo ""
  echo "  1) Hyprland   — Visual completo Lune OS (recomendado, requer GPU real)"
  echo "  2) KDE Plasma — Tema Lune no KDE (funciona em VM)"
  echo "  3) GNOME      — Tema Lune no GNOME (funciona em VM)"
  echo "  4) Manter atual ($DESKTOP_NAME)"
  echo ""
  read -rp "Escolha [1-4]: " choice

  case "$choice" in
    1) INSTALL_DESKTOP="hyprland" ;;
    2) INSTALL_DESKTOP="kde" ;;
    3) INSTALL_DESKTOP="gnome" ;;
    4) INSTALL_DESKTOP="$DESKTOP" ;;
    *) INSTALL_DESKTOP="hyprland" ;;
  esac

  log_ok "Ambiente escolhido: $INSTALL_DESKTOP"
}

# ── Instalar Hyprland ────────────────────────────────────────
install_hyprland() {
  log_step "Instalando Hyprland + componentes Lune OS"

  # Pacotes Oficiais
  sudo pacman -S --noconfirm --needed \
    hyprland \
    rofi-wayland kitty \
    qt6-declarative qt6-multimedia python-requests \
    swaync hyprlock hypridle \
    swww \
    xdg-desktop-portal-hyprland \
    polkit-kde-agent \
    wl-clipboard cliphist \
    grim slurp \
    wlogout playerctl brightnessctl \
    network-manager-applet blueman

  # Conflito conhecido: hypryou-utils substitui hyprland-guiutils
  if pacman -Q hyprland-guiutils &>/dev/null; then
    log_warn "Pacote conflitante detectado: hyprland-guiutils"
    log_info "Removendo hyprland-guiutils para permitir instalação do hypryou-utils"
    sudo pacman -Rns --noconfirm hyprland-guiutils || \
      log_error "Falha ao remover hyprland-guiutils. Remova manualmente e execute novamente."
  fi

  # Pacotes AUR
  if command -v yay &>/dev/null; then
    yay -S --noconfirm --needed quickshell-git matugen-bin hypryou-utils wallust
  elif command -v paru &>/dev/null; then
    paru -S --noconfirm --needed quickshell-git matugen-bin hypryou-utils wallust
  else
    log_warn "yay ou paru não encontrados. Por favor, instale quickshell-git, matugen-bin, hypryou-utils e wallust via AUR."
  fi

  # Python dependencies for Media Hub
  python3 -m pip install --user curl_cffi requests 2>/dev/null || \
    log_warn "Falha ao instalar dependências Python via pip. O Media Hub pode não funcionar."

  log_ok "Hyprland instalado"
}

# ── Instalar KDE ─────────────────────────────────────────────
install_kde() {
  log_step "Instalando KDE Plasma com tema Lune"

  sudo pacman -S --noconfirm --needed \
    plasma-desktop plasma-pa plasma-nm \
    dolphin konsole kscreen \
    kde-gtk-config breeze breeze-gtk \
    sddm

  sudo systemctl enable sddm
  log_ok "KDE Plasma instalado"
}

# ── Instalar GNOME ───────────────────────────────────────────
install_gnome() {
  log_step "Instalando GNOME com tema Lune"

  sudo pacman -S --noconfirm --needed \
    gnome gnome-tweaks \
    gdm

  sudo systemctl enable gdm
  log_ok "GNOME instalado"
}

# ── Aplicar dotfiles Hyprland ────────────────────────────────
apply_hyprland_dotfiles() {
  log_step "Aplicando dotfiles Hyprland do Lune OS"

  CONFIG="$HOME/.config"
  DOTFILES="$REPO_DIR/dotfiles"

  # Backup
  for dir in hypr waybar rofi kitty swaync hyprlock; do
    if [ -d "$CONFIG/$dir" ]; then
      mv "$CONFIG/$dir" "$CONFIG/$dir.bkp.$(date +%Y%m%d%H%M%S)"
      log_info "Backup criado: $dir"
    fi
  done

  # Copiar dotfiles
  mkdir -p "$CONFIG/hypr/conf" "$CONFIG/hypr/scripts"
  cp "$DOTFILES/hypr/hyprland.conf"     "$CONFIG/hypr/"
  cp "$DOTFILES/hypr/conf/"*.conf       "$CONFIG/hypr/conf/"
  cp "$DOTFILES/hypr/scripts/"*.sh      "$CONFIG/hypr/scripts/" 2>/dev/null || true
  chmod +x "$CONFIG/hypr/scripts/"*.sh  2>/dev/null || true

  cp -r "$DOTFILES/waybar"   "$CONFIG/"
  cp -r "$DOTFILES/rofi"     "$CONFIG/"
  cp -r "$DOTFILES/kitty"    "$CONFIG/"
  cp -r "$DOTFILES/swaync"   "$CONFIG/"
  cp -r "$DOTFILES/hyprlock" "$CONFIG/"
  cp -r "$DOTFILES/hypridle" "$CONFIG/" 2>/dev/null || true

  # Criar diretório Lune
  mkdir -p "$HOME/.config/lune/wallpapers"

  log_ok "Dotfiles Hyprland aplicados"
}

# ── Aplicar tema KDE Lune ────────────────────────────────────
apply_kde_theme() {
  log_step "Aplicando tema Lune Dark no KDE"

  mkdir -p ~/.local/share/color-schemes

  cat > ~/.local/share/color-schemes/LuneDark.colors << 'COLORS'
[General]
ColorScheme=LuneDark
Name=Lune Dark

[Colors:Window]
BackgroundNormal=13,14,20
ForegroundNormal=232,232,240
DecorationFocus=200,168,233

[Colors:Button]
BackgroundNormal=26,27,38
ForegroundNormal=232,232,240
DecorationFocus=200,168,233

[Colors:Selection]
BackgroundNormal=200,168,233
ForegroundNormal=13,14,20

[Colors:View]
BackgroundNormal=13,14,20
ForegroundNormal=232,232,240
DecorationFocus=200,168,233

[WM]
activeBackground=13,14,20
activeForeground=200,168,233
inactiveBackground=13,14,20
inactiveForeground=160,160,176
COLORS

  log_ok "Tema Lune Dark criado para KDE"
  log_info "Aplique em: Configurações → Aparência → Esquema de Cores → Lune Dark"
}

# ── Aplicar tema GNOME Lune ──────────────────────────────────
apply_gnome_theme() {
  log_step "Aplicando tema Lune no GNOME"

  # Instalar extensões básicas
  sudo pacman -S --noconfirm --needed \
    gnome-shell-extensions 2>/dev/null || true

  # Configurar cores via gsettings
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface accent-color 'purple' 2>/dev/null || true

  log_ok "Tema Lune aplicado no GNOME"
}

# ── Executar scripts base ────────────────────────────────────
run_base_scripts() {
  log_step "Aplicando configurações base do Lune OS"

  bash "$SCRIPT_DIR/gpu-detect.sh"
  bash "$SCRIPT_DIR/performance.sh"
  bash "$SCRIPT_DIR/folders.sh"

  if [ "$INSTALL_DESKTOP" = "hyprland" ]; then
    bash "$SCRIPT_DIR/binfmt.sh"
    bash "$SCRIPT_DIR/wallust.sh" --setup
  fi

  log_ok "Configurações base aplicadas"
}

# ── Instalar pacotes comuns ──────────────────────────────────
install_common() {
  log_step "Instalando pacotes essenciais"

  local packages=(
    wine wine-mono flatpak timeshift
    noto-fonts inter-font ttf-jetbrains-mono-nerd
    nautilus vlc libreoffice-fresh blueman cups xdg-user-dirs
  )

  for pkg in "${packages[@]}"; do
    sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null ||       log_warn "Pacote nao encontrado: $pkg — pulando"
  done

  flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

  log_ok "Pacotes essenciais instalados"
}

# ── Configurar SDDM ──────────────────────────────────────────
setup_sddm() {
  log_step "Configurando tema de login SDDM"
  bash "$SCRIPT_DIR/setup-sddm.sh" 2>/dev/null || \
    log_warn "SDDM não configurado — rode setup-sddm.sh manualmente"
}

# ── Finalização ──────────────────────────────────────────────
finish() {
  echo ""
  echo -e "${GREEN}✅ Lune OS instalado com sucesso!${NC}"
  echo -e "${CYAN}Ambiente: $INSTALL_DESKTOP${NC}"
  echo ""

  case "$INSTALL_DESKTOP" in
    hyprland)
      echo "  1. Reinicie: sudo reboot"
      echo "  2. Na tela de login selecione: Hyprland"
      echo "  3. Super+Espaço → launcher de apps"
      echo "  4. Super+F1 → todos os atalhos"
      ;;
    kde)
      echo "  1. Reinicie: sudo reboot"
      echo "  2. Entre no KDE normalmente"
      echo "  3. Configurações → Aparência → Lune Dark"
      ;;
    gnome)
      echo "  1. Reinicie: sudo reboot"
      echo "  2. Entre no GNOME normalmente"
      echo "  3. O tema escuro já foi aplicado"
      ;;
  esac

  echo ""
  echo -e "${PURPLE}🌙 Your world, just lighter.${NC}"
  echo ""

  read -rp "Reiniciar agora? [s/N] " reboot_now
  [[ "$reboot_now" =~ ^[Ss]$ ]] && sudo reboot
}

# ── Main ─────────────────────────────────────────────────────
main() {
  banner
  detect_desktop
  choose_desktop
  install_common

  case "$INSTALL_DESKTOP" in
    hyprland)
      install_hyprland
      apply_hyprland_dotfiles
      ;;
    kde|*plasma*)
      install_kde
      apply_kde_theme
      ;;
    gnome)
      install_gnome
      apply_gnome_theme
      ;;
    *)
      log_warn "Desktop não reconhecido — aplicando apenas configurações base"
      ;;
  esac

  run_base_scripts
  setup_sddm
  finish
}

main "$@"
