#!/bin/bash
# Lune OS — Detecção de GPU
# Compatível com Codespaces (Ubuntu/teste) e CachyOS (produção)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[GPU]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[GPU]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[GPU]${NC} $1"; }

GPU_VENDOR_FILE_USER="$HOME/.config/lune/gpu-vendor"
GPU_VENDOR_FILE_SYSTEM="/etc/lune/gpu-vendor"

# Detectar ambiente
IS_CODESPACES=false
IS_CACHYOS=false
[ -n "$CODESPACE_NAME" ] && IS_CODESPACES=true
grep -q "CachyOS" /etc/os-release 2>/dev/null && IS_CACHYOS=true

# ── Instalar pciutils conforme o ambiente ────────────────────
install_pciutils() {
  command -v lspci &>/dev/null && return 0
  log_info "Instalando pciutils..."
  if command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm --needed pciutils
  elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y -qq pciutils 2>/dev/null || true
  fi
}

# ── Detectar módulo NVIDIA já instalado ──────────────────────
nvidia_module_installed() {
  pacman -Qq 2>/dev/null | grep -Eq '(^|-)nvidia-open($|-)|(^|-)linux-cachyos.*nvidia-open|(^|-)nvidia-(535xx|550xx)-dkms($|-)|(^|-)nvidia-dkms($|-)' 
}

# ── Detectar GPU ─────────────────────────────────────────────
detect_gpu() {
  log_info "Detectando placa de vídeo..."
  install_pciutils

  if ! command -v lspci &>/dev/null; then
    log_warn "lspci não disponível — ambiente virtual"
    GPU_VENDOR="virtual"
    GPU_NAME="Virtual/Emulated GPU (ambiente de teste)"
    return
  fi

  GPU_INFO=$(lspci | grep -iE 'vga|3d|display' 2>/dev/null || echo "")

  if [ -z "$GPU_INFO" ]; then
    log_warn "Nenhuma GPU física detectada — ambiente virtual"
    GPU_VENDOR="virtual"
    GPU_NAME="Nenhuma GPU física detectada"
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
    GPU_NAME="GPU não reconhecida"
  fi
}

# ── Instalar driver (só no CachyOS real) ─────────────────────
install_driver() {
  # Verificar se ja tem mesa-git instalado (CachyOS usa mesa-git por padrao)
  if pacman -Qq mesa-git &>/dev/null 2>&1 || pacman -Qq lib32-mesa-git &>/dev/null 2>&1; then
    log_warn "mesa-git detectado — nao substituindo pilha Mesa (CachyOS usa versao de desenvolvimento)"
    log_ok "Driver AMD/Intel ja configurado via mesa-git"
    return 0
  fi
  if $IS_CODESPACES || [ "$GPU_VENDOR" = "virtual" ]; then
    log_warn "Codespaces — instalação de driver ignorada (apenas teste)"
    log_info "No CachyOS real instalaria o driver: $GPU_VENDOR"
    return
  fi

  if ! command -v pacman &>/dev/null; then
    log_warn "pacman não encontrado — não é CachyOS/Arch"
    return
  fi

  case "$GPU_VENDOR" in
    nvidia)
      local nvidia_packages=(nvidia-utils nvidia-settings libva-nvidia-driver lib32-nvidia-utils)

      if nvidia_module_installed; then
        log_warn "Módulo NVIDIA já detectado no sistema — pulando reinstalação do kernel module"
      else
        nvidia_packages=(nvidia-dkms "${nvidia_packages[@]}")
      fi

      sudo pacman -S --noconfirm --needed "${nvidia_packages[@]}"
      sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1
EOF
      sudo mkinitcpio -P 2>/dev/null || true
      log_ok "Driver NVIDIA configurado"
      ;;
    amd)
      sudo pacman -S --noconfirm --needed \
        mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver mesa-vdpau
      log_ok "Driver AMD instalado"
      ;;
    intel)
      sudo pacman -S --noconfirm --needed \
        mesa lib32-mesa vulkan-intel intel-media-driver
      log_ok "Driver Intel instalado"
      ;;
  esac
}

# ── Salvar vendor ────────────────────────────────────────────
save_vendor() {
  mkdir -p "$HOME/.config/lune"
  echo "$GPU_VENDOR" > "$GPU_VENDOR_FILE_USER"
  mkdir -p /etc/lune 2>/dev/null || true
  if command -v sudo &>/dev/null; then
    sudo mkdir -p /etc/lune 2>/dev/null || true
    echo "$GPU_VENDOR" | sudo tee "$GPU_VENDOR_FILE_SYSTEM" >/dev/null 2>&1 || true
  fi
  log_info "Vendor salvo em ~/.config/lune/gpu-vendor"
}

# ── Relatório ────────────────────────────────────────────────
show_report() {
  echo ""
  echo -e "${GREEN}════════════════════════════════════${NC}"
  echo -e "${GREEN} Lune OS — Detecção de GPU${NC}"
  echo -e "${GREEN}════════════════════════════════════${NC}"
  echo -e " GPU:        ${BLUE}$GPU_NAME${NC}"
  echo -e " Fabricante: ${BLUE}$GPU_VENDOR${NC}"
  if $IS_CODESPACES; then
    echo ""
    echo -e " ${YELLOW}Ambiente: Codespaces (teste)${NC}"
    echo -e " ${YELLOW}No CachyOS real instalaria:${NC}"
    case "$GPU_VENDOR" in
      nvidia)  echo "   sudo pacman -S nvidia-dkms nvidia-utils" ;;
      amd)     echo "   sudo pacman -S mesa vulkan-radeon" ;;
      intel)   echo "   sudo pacman -S mesa vulkan-intel" ;;
      *)       echo "   sudo pacman -S mesa (fallback)" ;;
    esac
  fi
  echo -e "${GREEN}════════════════════════════════════${NC}"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────
main() {
  detect_gpu
  install_driver
  save_vendor
  show_report
}

main "$@"
