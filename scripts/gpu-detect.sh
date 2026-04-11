#!/bin/bash
# Lune OS — Detecção e Instalação de Driver GPU
# Detecta automaticamente NVIDIA, AMD ou Intel e instala o driver correto

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

# ── Detectar GPU ─────────────────────────────────────────────
detect_gpu() {
  log_info "Detectando placa de vídeo..."

  GPU_INFO=$(lspci | grep -iE 'vga|3d|display' 2>/dev/null || echo "")

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

  # Verificar se é GPU legada
  NVIDIA_ID=$(lspci -n | grep -iE '(0300|0302).*10de' | awk '{print $3}' | cut -d: -f2 | head -1)

  # Instalar driver principal
  sudo pacman -S --noconfirm --needed \
    nvidia-dkms \
    nvidia-utils \
    nvidia-settings \
    libva-nvidia-driver \
    lib32-nvidia-utils

  # Configurar módulos do kernel para Wayland
  sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1
EOF

  # Adicionar módulos ao initramfs
  sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' \
    /etc/mkinitcpio.conf 2>/dev/null || true

  sudo mkinitcpio -P 2>/dev/null || true

  # Configurar variáveis de ambiente para Hyprland
  NVIDIA_ENV="$HOME/.config/hypr/conf/nvidia.conf"
  mkdir -p "$(dirname "$NVIDIA_ENV")"
  cat > "$NVIDIA_ENV" <<EOF
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

  sudo pacman -S --noconfirm --needed \
    mesa \
    lib32-mesa \
    vulkan-radeon \
    lib32-vulkan-radeon \
    libva-mesa-driver \
    lib32-libva-mesa-driver \
    mesa-vdpau \
    lib32-mesa-vdpau \
    xf86-video-amdgpu

  # AMD não precisa de configs extras no Hyprland — funciona nativamente
  log_ok "Driver AMD instalado (open source, sem configuração extra necessária)"
}

# ── Instalar driver Intel ────────────────────────────────────
install_intel() {
  log_info "Instalando driver Intel..."

  sudo pacman -S --noconfirm --needed \
    mesa \
    lib32-mesa \
    vulkan-intel \
    lib32-vulkan-intel \
    intel-media-driver \
    libva-intel-driver

  log_ok "Driver Intel instalado"
}

# ── Configurar timer de atualização de driver ────────────────
setup_driver_update_timer() {
  log_info "Configurando verificação diária de atualização de driver..."

  sudo tee /etc/systemd/system/lune-gpu-update.service > /dev/null <<EOF
[Unit]
Description=Lune OS — Verificação de Atualização de Driver GPU
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/lune-gpu-check.sh
StandardOutput=journal
EOF

  sudo tee /etc/systemd/system/lune-gpu-update.timer > /dev/null <<EOF
[Unit]
Description=Lune OS — Timer de Verificação de Driver GPU

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

  sudo tee /usr/local/bin/lune-gpu-check.sh > /dev/null <<'EOF'
#!/bin/bash
# Verifica e atualiza driver GPU silenciosamente
VENDOR_FILE="/etc/lune/gpu-vendor"
[ -f "$VENDOR_FILE" ] || exit 0
VENDOR=$(cat "$VENDOR_FILE")

case "$VENDOR" in
  nvidia)
    pacman -Qu nvidia-dkms nvidia-utils 2>/dev/null | grep -q . && \
      pacman -S --noconfirm nvidia-dkms nvidia-utils 2>/dev/null || true
    ;;
  amd|intel)
    pacman -Qu mesa 2>/dev/null | grep -q . && \
      pacman -S --noconfirm mesa lib32-mesa 2>/dev/null || true
    ;;
esac
EOF

  sudo chmod +x /usr/local/bin/lune-gpu-check.sh

  # Salvar vendor detectado
  sudo mkdir -p /etc/lune
  echo "$GPU_VENDOR" | sudo tee /etc/lune/gpu-vendor > /dev/null

  sudo systemctl daemon-reload
  sudo systemctl enable --now lune-gpu-update.timer

  log_ok "Timer de atualização de driver configurado"
}

# ── Verificar instalação ─────────────────────────────────────
verify_driver() {
  log_info "Verificando driver instalado..."

  case "$GPU_VENDOR" in
    nvidia)
      if pacman -Qi nvidia-dkms &>/dev/null; then
        log_ok "Driver NVIDIA instalado e verificado"
      else
        log_warn "Driver NVIDIA pode não ter sido instalado corretamente"
      fi
      ;;
    amd|intel)
      if pacman -Qi mesa &>/dev/null; then
        log_ok "Driver mesa instalado e verificado"
      else
        log_warn "Driver mesa pode não ter sido instalado"
      fi
      ;;
  esac
}

# ── Main ─────────────────────────────────────────────────────
main() {
  detect_gpu

  case "$GPU_VENDOR" in
    nvidia)  install_nvidia ;;
    amd)     install_amd ;;
    intel)   install_intel ;;
    unknown)
      log_warn "GPU não reconhecida. Instalando mesa como fallback..."
      sudo pacman -S --noconfirm --needed mesa lib32-mesa
      ;;
  esac

  setup_driver_update_timer
  verify_driver

  echo ""
  log_ok "Configuração de GPU concluída para: $GPU_NAME ($GPU_VENDOR)"
}

main "$@"
