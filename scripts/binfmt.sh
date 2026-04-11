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

detect_pkg_manager() {
  if command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    log_info "Gerenciador: pacman (Arch/CachyOS)"
  elif command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
    log_info "Gerenciador: apt (Ubuntu/Codespaces)"
  else
    PKG_MANAGER="unknown"
  fi
}

detect_environment() {
  IS_VIRTUAL=false
  if ! grep -q "binfmt_misc" /proc/filesystems 2>/dev/null; then
    IS_VIRTUAL=true
  fi
  if ! systemctl is-system-running &>/dev/null; then
    IS_VIRTUAL=true
  fi
}

install_wine() {
  log_info "Verificando Wine..."

  if command -v wine &>/dev/null; then
    log_ok "Wine já instalado"
    return 0
  fi

  log_info "Instalando Wine..."

  case "$PKG_MANAGER" in
    pacman)
      sudo pacman -S --noconfirm --needed wine wine-mono
      ;;
    apt)
      sudo dpkg --add-architecture i386 2>/dev/null || true
      sudo apt-get update -qq
      sudo apt-get install -y wine 2>/dev/null || \
      sudo apt-get install -y wine64 2>/dev/null || {
        log_warn "Wine não disponível nos repos padrão"
        log_info "No sistema real (CachyOS), Wine instalado via pacman automaticamente"
        return 1
      }
      ;;
    *)
      log_warn "Instale Wine manualmente"
      return 1
      ;;
  esac

  log_ok "Wine instalado"
}

enable_binfmt() {
  sudo modprobe binfmt_misc 2>/dev/null || return 1
  if ! mountpoint -q /proc/sys/fs/binfmt_misc 2>/dev/null; then
    sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null || return 1
  fi
  log_ok "binfmt_misc ativo"
  return 0
}

register_exe() {
  local WINE_PATH
  WINE_PATH=$(which wine 2>/dev/null || echo "/usr/bin/wine")

  echo ":WindowsExe:M::MZ::${WINE_PATH}:UTC" | \
    sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null 2>&1 && \
    log_ok ".exe registrado" || log_warn "Não foi possível registrar .exe"

  echo ":WindowsMSI:E::msi::${WINE_PATH}:UTC" | \
    sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null 2>&1 && \
    log_ok ".msi registrado" || log_warn "Não foi possível registrar .msi"
}

persist_binfmt() {
  local WINE_PATH
  WINE_PATH=$(which wine 2>/dev/null || echo "/usr/bin/wine")

  sudo mkdir -p /usr/lib/binfmt.d
  sudo tee /usr/lib/binfmt.d/wine.conf > /dev/null <<EOF
# Lune OS — binfmt_misc para arquivos Windows
:WindowsExe:M::MZ::${WINE_PATH}:UTC
:WindowsMSI:E::msi::${WINE_PATH}:UTC
EOF

  if systemctl is-system-running &>/dev/null; then
    sudo systemctl enable systemd-binfmt.service 2>/dev/null || true
    sudo systemctl start systemd-binfmt.service 2>/dev/null || true
    log_ok "Persistido via systemd — ativo em todo boot"
  else
    log_ok "Config salva em /usr/lib/binfmt.d/wine.conf"
    log_info "Será ativado automaticamente no sistema real"
  fi
}

simulate_binfmt() {
  log_warn "Ambiente virtual/container detectado"
  log_info "Preparando configuração para o sistema real..."

  sudo mkdir -p /usr/lib/binfmt.d
  sudo tee /usr/lib/binfmt.d/wine.conf > /dev/null <<'EOF'
# Lune OS — binfmt_misc
:WindowsExe:M::MZ::/usr/bin/wine:UTC
:WindowsMSI:E::msi::/usr/bin/wine:UTC
EOF

  echo ""
  log_ok "Arquivo de configuração criado: /usr/lib/binfmt.d/wine.conf"
  log_ok "No sistema real (CachyOS) isso acontecerá automaticamente:"
  log_info "  1. Wine instalado via pacman"
  log_info "  2. binfmt_misc carregado no kernel"
  log_info "  3. .exe e .msi registrados"
  log_info "  4. Ativo em todo boot via systemd"
  log_info "  5. Usuario clica em .exe → abre direto, sem saber que Wine existe"
}

setup_wine_prefix() {
  command -v wine &>/dev/null || return
  local WINE_PREFIX="$HOME/.wine-lune"
  if [ ! -d "$WINE_PREFIX" ]; then
    log_info "Criando prefixo Wine em $WINE_PREFIX..."
    WINEPREFIX="$WINE_PREFIX" WINEARCH=win64 wineboot --init 2>/dev/null || true
  fi
  mkdir -p "$HOME/.config/hypr/conf"
  grep -q "WINEPREFIX" "$HOME/.config/hypr/conf/environment.conf" 2>/dev/null || \
    echo "env = WINEPREFIX,$WINE_PREFIX" >> "$HOME/.config/hypr/conf/environment.conf"
  log_ok "Prefixo Wine: $WINE_PREFIX"
}

main() {
  detect_pkg_manager
  detect_environment
  install_wine || true

  if $IS_VIRTUAL; then
    simulate_binfmt
  else
    if enable_binfmt; then
      register_exe
      persist_binfmt
      setup_wine_prefix
      echo ""
      log_ok "binfmt_misc configurado! Arquivos .exe abrem automaticamente."
    else
      persist_binfmt
      log_info "Config salva — será ativada no próximo boot"
    fi
  fi
}

main "$@"
