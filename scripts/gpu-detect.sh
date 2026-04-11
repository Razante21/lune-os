#!/bin/bash
# Lune OS — Detecção e Instalação de Driver GPU
# Detecta automaticamente NVIDIA, AMD ou Intel e instala o driver correto
# Compatível com: pacman (Arch/CachyOS) e apt (Ubuntu/Codespaces)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[GPU]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[GPU]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[GPU]${NC} $1"; }
log_error() { echo -e "${RED}[GPU]${NC} $1"; }

# ── Detectar gerenciador de pacotes ─────────────────────────
detect_pkg_manager() {
  if command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    PKG_INSTALL="sudo pacman -S --noconfirm --needed"
    log_info "Gerenciador de pacotes: pacman (Arch/CachyOS)"
  elif command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
    PKG_INSTALL="sudo apt-get install -y"
    log_info "Gerenciador de pacotes: apt (Ubuntu/Debian)"
  else
    log_warn "Gerenciador de pacotes não identificado"
    PKG_MANAGER="unknown"
    PKG_INSTALL="echo [SIMULANDO INSTALAÇÃO]"
  fi
}

# ── Instalar dependência lspci ───────────────────────────────
ensure_lspci() {
  if ! command -v lspci &>/dev/null; then
    log_info "Instalando pciutils (necessário para detectar GPU)..."
    case "$PKG_MANAGER" in
      pacman) sudo pacman -S --noconfirm --needed pciutils ;;
      apt)    sudo apt-get install -y pciutils ;;
      *)      log_warn "Instale pciutils manualmente" ;;
    esac
  fi
}

# ── Detectar GPU ─────────────────────────────────────────────
detect_gpu() {
  log_info "Detectando placa de vídeo..."

  GPU_INFO=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' || echo "")

  if [ -z "$GPU_INFO" ]; then
    log_warn "Nenhuma GPU detectada via lspci"
    log_warn "Isso é normal em ambientes virtuais (Codespaces, VM sem GPU passthrough)"
    GPU_VENDOR="virtual"
    GPU_NAME="Ambiente Virtual / Sem GPU dedicada"
    return
  fi

  if echo "$GPU_INFO" | grep -qi "nvidia"; then
    GPU_VENDOR="nvidia"
    GPU_NAME=$(echo "$GPU_INFO" | grep -i nvidia | head -1 | sed 's/.*: //')
  elif echo "$GPU_INFO" | grep -qi "amd\|radeon\|ati"; then
    GPU_VENDOR="amd"
    GPU_NAME=$(echo "$GPU_INFO" | grep -iE "amd|radeon|ati" | head -1 | sed 's/.*: //')
  elif echo "$GPU_INFO" | grep -qi "intel"; then
    GPU_VENDOR="intel"
    GPU_NAME=$(echo "$GPU_INFO" | grep -i intel | head -1 | sed 's/.*: //')
  else
    GPU_VENDOR="unknown"
    GPU_NAME="Desconhecida"
  fi

  log_ok "GPU detectada: $GPU_NAME"
  log_info "Fabricante: $GPU_VENDOR"
}

# ── Instalar driver NVIDIA ───────────────────────────────────
install_nvidia() {
  log_info "Instalando driver NVIDIA proprietário..."

  case "$PKG_MANAGER" in
    pacman)
      sudo pacman -S --noconfirm --needed \
        nvidia-dkms nvidia-utils nvidia-settings \
        libva-nvidia-driver lib32-nvidia-utils

      # Configurar módulos para Wayland
      sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1
EOF
      sudo mkinitcpio -P 2>/dev/null || true
      ;;
    apt)
      sudo apt-get install -y nvidia-driver-535 nvidia-utils-535
      log_warn "No Ubuntu, considere usar ubuntu-drivers autoinstall"
      ;;
    *)
      log_warn "Instale o driver NVIDIA manualmente para seu sistema"
      ;;
  esac

  # Configurar variáveis de ambiente para Hyprland
  mkdir -p "$HOME/.config/hypr/conf"
  cat > "$HOME/.config/hypr/conf/nvidia.conf" <<EOF
# Lune OS — Variáveis de ambiente NVIDIA para Hyprland
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,0
env = ELECTRON_OZONE_PLATFORM_HINT,auto
EOF

  log_ok "Driver NVIDIA instalado e configurado para Wayland"
}

# ── Instalar driver AMD ──────────────────────────────────────
install_amd() {
  log_info "Instalando driver AMD (mesa + vulkan)..."

  case "$PKG_MANAGER" in
    pacman)
      sudo pacman -S --noconfirm --needed \
        mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon \
        libva-mesa-driver lib32-libva-mesa-driver \
        mesa-vdpau lib32-mesa-vdpau xf86-video-amdgpu
      ;;
    apt)
      sudo apt-get install -y mesa-vulkan-drivers libvulkan1 \
        mesa-va-drivers mesa-vdpau-drivers
      ;;
    *)
      log_warn "Instale mesa e vulkan-radeon manualmente"
      ;;
  esac

  log_ok "Driver AMD instalado (open source, Wayland nativo)"
}

# ── Instalar driver Intel ────────────────────────────────────
install_intel() {
  log_info "Instalando driver Intel..."

  case "$PKG_MANAGER" in
    pacman)
      sudo pacman -S --noconfirm --needed \
        mesa lib32-mesa vulkan-intel lib32-vulkan-intel \
        intel-media-driver libva-intel-driver
      ;;
    apt)
      sudo apt-get install -y mesa-vulkan-drivers \
        intel-media-va-driver libvulkan1
      ;;
    *)
      log_warn "Instale mesa e vulkan-intel manualmente"
      ;;
  esac

  log_ok "Driver Intel instalado"
}

# ── Configurar timer de atualização de driver ────────────────
setup_driver_update_timer() {
  # Só configura em sistemas com systemd real (não Codespaces)
  if ! systemctl is-system-running &>/dev/null; then
    log_warn "systemd não disponível — pulando configuração do timer"
    log_info "Timer de atualização de driver será configurado no sistema real"
    return
  fi

  log_info "Configurando verificação diária de atualização de driver..."

  sudo mkdir -p /etc/lune
  echo "$GPU_VENDOR" | sudo tee /etc/lune/gpu-vendor > /dev/null

  sudo tee /usr/local/bin/lune-gpu-check.sh > /dev/null <<'EOF'
#!/bin/bash
VENDOR=$(cat /etc/lune/gpu-vendor 2>/dev/null || exit 0)
case "$VENDOR" in
  nvidia)
    pacman -Qu nvidia-dkms nvidia-utils 2>/dev/null | grep -q . && \
      pacman -S --noconfirm nvidia-dkms nvidia-utils 2>/dev/null || true ;;
  amd|intel)
    pacman -Qu mesa 2>/dev/null | grep -q . && \
      pacman -S --noconfirm mesa lib32-mesa 2>/dev/null || true ;;
esac
EOF
  sudo chmod +x /usr/local/bin/lune-gpu-check.sh

  sudo tee /etc/systemd/system/lune-gpu-update.timer > /dev/null <<EOF
[Unit]
Description=Lune OS — Timer de Verificação de Driver GPU
[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true
[Install]
WantedBy=timers.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now lune-gpu-update.timer 2>/dev/null || true
  log_ok "Timer de atualização de driver configurado"
}

# ── Salvar resultado da detecção ─────────────────────────────
save_detection() {
  sudo mkdir -p /etc/lune
  echo "$GPU_VENDOR" | sudo tee /etc/lune/gpu-vendor > /dev/null 2>&1 || true
  echo "$GPU_NAME"   | sudo tee /etc/lune/gpu-name   > /dev/null 2>&1 || true
  log_info "Resultado salvo em /etc/lune/gpu-vendor"
}

# ── Main ─────────────────────────────────────────────────────
main() {
  detect_pkg_manager
  ensure_lspci
  detect_gpu

  case "$GPU_VENDOR" in
    nvidia)  install_nvidia ;;
    amd)     install_amd ;;
    intel)   install_intel ;;
    virtual)
      log_warn "Ambiente virtual detectado — pulando instalação de driver"
      log_info "No sistema real, o driver será instalado automaticamente"
      ;;
    unknown)
      log_warn "GPU não reconhecida — instalando mesa como fallback..."
      case "$PKG_MANAGER" in
        pacman) sudo pacman -S --noconfirm --needed mesa lib32-mesa ;;
        apt)    sudo apt-get install -y mesa-vulkan-drivers ;;
      esac
      ;;
  esac

  save_detection
  setup_driver_update_timer

  echo ""
  log_ok "Detecção de GPU concluída!"
  log_ok "GPU: $GPU_NAME"
  log_ok "Fabricante: $GPU_VENDOR"
  log_ok "Gerenciador de pacotes: $PKG_MANAGER"
}

main "$@"
