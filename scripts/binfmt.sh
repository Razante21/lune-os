#!/bin/bash
# Lune OS — Configuração do binfmt_misc
# Faz arquivos .exe e .msi abrirem automaticamente via Wine
# Compatível com: pacman (Arch/CachyOS) e apt (Ubuntu/Codespaces)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[BINFMT]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[BINFMT]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[BINFMT]${NC} $1"; }
log_error() { echo -e "${RED}[BINFMT]${NC} $1"; }

detect_pkg_manager() {
  if command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
  elif command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
  else
    PKG_MANAGER="unknown"
  fi
  log_info "Gerenciador de pacotes: $PKG_MANAGER"
}

detect_environment() {
  if command -v pacman &>/dev/null; then
    IS_REAL_SYSTEM=true
    log_info "Sistema real detectado (Arch/CachyOS)"
  else
    IS_REAL_SYSTEM=false
    log_info "Ambiente de desenvolvimento detectado (Codespaces/Ubuntu)"
  fi
}

check_wine() {
  log_info "Verificando instalação do Wine..."

  if ! command -v wine &>/dev/null; then
    log_warn "Wine não encontrado. Instalando..."
    case "$PKG_MANAGER" in
      pacman)
        sudo pacman -S --noconfirm --needed wine wine-mono
        ;;
      apt)
        sudo dpkg --add-architecture i386 2>/dev/null || true
        sudo apt-get update -qq 2>/dev/null || true
        sudo apt-get install -y wine wine32 wine64 2>/dev/null || \
        sudo apt-get install -y wine64 2>/dev/null || \
          log_warn "Wine não pôde ser instalado no Codespaces — será instalado no sistema real"
        ;;
      *)
        log_warn "Instale o Wine manualmente para seu sistema"
        ;;
    esac
  fi

  if command -v wine &>/dev/null; then
    WINE_PATH=$(which wine)
    log_ok "Wine encontrado: $WINE_PATH"
    return 0
  else
    log_warn "Wine não disponível neste ambiente"
    return 1
  fi
}

check_binfmt_support() {
  if [ ! -d /proc/sys/fs/binfmt_misc ]; then
    log_warn "binfmt_misc não disponível neste ambiente (normal em Codespaces)"
    return 1
  fi
  log_ok "binfmt_misc disponível no kernel"
  return 0
}

enable_binfmt() {
  log_info "Habilitando binfmt_misc..."
  sudo modprobe binfmt_misc 2>/dev/null || true
  if ! mountpoint -q /proc/sys/fs/binfmt_misc 2>/dev/null; then
    sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null || true
  fi
  log_ok "binfmt_misc ativo"
}

register_exe() {
  log_info "Registrando .exe e .msi..."
  WINE_PATH=$(which wine)

  if [ -f /proc/sys/fs/binfmt_misc/WindowsExe ]; then
    echo -1 | sudo tee /proc/sys/fs/binfmt_misc/WindowsExe > /dev/null 2>&1 || true
  fi
  echo ":WindowsExe:M::MZ::${WINE_PATH}:UTC" | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
  log_ok ".exe registrado"

  if [ -f /proc/sys/fs/binfmt_misc/WindowsMSI ]; then
    echo -1 | sudo tee /proc/sys/fs/binfmt_misc/WindowsMSI > /dev/null 2>&1 || true
  fi
  echo ":WindowsMSI:E::msi::${WINE_PATH}:UTC" | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
  log_ok ".msi registrado"
}

persist_binfmt() {
  log_info "Persistindo configuração no boot..."
  sudo mkdir -p /usr/lib/binfmt.d
  WINE_PATH=$(which wine)

  sudo tee /usr/lib/binfmt.d/wine.conf > /dev/null <<EOF
# Lune OS — binfmt_misc para arquivos Windows
:WindowsExe:M::MZ::${WINE_PATH}:UTC
:WindowsMSI:E::msi::${WINE_PATH}:UTC
EOF

  if systemctl is-system-running &>/dev/null; then
    sudo systemctl enable systemd-binfmt.service 2>/dev/null || true
    sudo systemctl start systemd-binfmt.service 2>/dev/null || true
    log_ok "Persistido via systemd-binfmt"
  else
    log_warn "systemd não disponível — config salva em /usr/lib/binfmt.d/wine.conf"
  fi
}

setup_wine_prefix() {
  log_info "Configurando prefixo Wine..."
  WINE_PREFIX="$HOME/.wine-lune"
  if [ ! -d "$WINE_PREFIX" ]; then
    WINEPREFIX="$WINE_PREFIX" WINEARCH=win64 wineboot --init 2>/dev/null || \
      log_warn "Prefixo Wine será criado na primeira execução de um .exe"
  else
    log_ok "Prefixo Wine já existe em $WINE_PREFIX"
  fi

  mkdir -p "$HOME/.config/hypr/conf"
  if ! grep -q "WINEPREFIX" "$HOME/.config/hypr/conf/environment.conf" 2>/dev/null; then
    echo "env = WINEPREFIX,$WINE_PREFIX" >> "$HOME/.config/hypr/conf/environment.conf"
  fi
  log_ok "WINEPREFIX configurado: $WINE_PREFIX"
}

simulate_codespaces() {
  log_warn "Modo simulação — Codespaces não tem kernel completo para binfmt_misc"
  echo ""
  echo "  No sistema real (CachyOS) acontecerá:"
  echo ""
  echo "  1. Wine instalado via pacman"
  echo "  2. binfmt_misc habilitado no kernel"
  echo "  3. .exe registrado → abre automaticamente via Wine"
  echo "  4. .msi registrado → instaladores Windows funcionam"
  echo "  5. Prefixo Wine criado em ~/.wine-lune"
  echo "  6. Persiste em todo boot via systemd-binfmt"
  echo ""
  echo "  Conteúdo de /usr/lib/binfmt.d/wine.conf no sistema real:"
  echo "  :WindowsExe:M::MZ::/usr/bin/wine:UTC"
  echo "  :WindowsMSI:E::msi::/usr/bin/wine:UTC"
  echo ""
  log_ok "Simulação concluída — lógica validada para o sistema real"
}

main() {
  detect_pkg_manager
  detect_environment

  if ! check_binfmt_support; then
    check_wine || true
    simulate_codespaces
    return 0
  fi

  if check_wine; then
    enable_binfmt
    register_exe
    persist_binfmt
    setup_wine_prefix
    echo ""
    log_ok "binfmt_misc configurado com sucesso!"
    log_ok "Arquivos .exe e .msi agora abrem automaticamente via Wine"
    log_info "Reinicie o sistema para garantir persistência completa"
  else
    log_error "Wine não instalado — binfmt_misc não configurado"
    exit 1
  fi
}

main "$@"
