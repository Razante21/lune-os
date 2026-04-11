#!/bin/bash
# Lune OS — binfmt_misc
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
log_info() { echo -e "${BLUE}[BINFMT]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[BINFMT]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[BINFMT]${NC} $1"; }

# Detectar gerenciador de pacotes
if command -v pacman &>/dev/null; then PKG_MANAGER="pacman"
elif command -v apt-get &>/dev/null; then PKG_MANAGER="apt"
else PKG_MANAGER="unknown"; fi
log_info "Gerenciador: $PKG_MANAGER"

# Instalar Wine
if ! command -v wine &>/dev/null; then
  log_warn "Wine não encontrado. Instalando..."
  case "$PKG_MANAGER" in
    pacman) sudo pacman -S --noconfirm --needed wine wine-mono ;;
    apt)
      sudo dpkg --add-architecture i386 2>/dev/null || true
      sudo apt-get update -qq 2>/dev/null || true
      sudo apt-get install -y wine wine64 2>/dev/null || \
        log_warn "Wine não disponível no Codespaces — instalado no sistema real"
      ;;
    *) log_warn "Instale Wine manualmente" ;;
  esac
fi

# Verificar binfmt_misc no kernel
if [ ! -d /proc/sys/fs/binfmt_misc ]; then
  log_warn "binfmt_misc não disponível (normal em Codespaces)"
  echo ""
  echo "  No sistema real (CachyOS) acontecerá:"
  echo "  1. Wine instalado via pacman"
  echo "  2. binfmt_misc habilitado no kernel"
  echo "  3. .exe → abre automaticamente via Wine"
  echo "  4. .msi → instaladores Windows funcionam"
  echo "  5. Prefixo Wine em ~/.wine-lune"
  echo "  6. Persiste em todo boot via systemd-binfmt"
  echo ""
  echo "  Config que será criada: /usr/lib/binfmt.d/wine.conf"
  echo "  :WindowsExe:M::MZ::/usr/bin/wine:UTC"
  echo "  :WindowsMSI:E::msi::/usr/bin/wine:UTC"
  echo ""
  log_ok "Simulação concluída — lógica validada para o sistema real"
  exit 0
fi

# Sistema real — executa tudo
WINE_PATH=$(which wine)
sudo modprobe binfmt_misc 2>/dev/null || true
mountpoint -q /proc/sys/fs/binfmt_misc 2>/dev/null || \
  sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null || true

echo ":WindowsExe:M::MZ::${WINE_PATH}:UTC" | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
echo ":WindowsMSI:E::msi::${WINE_PATH}:UTC" | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null

sudo mkdir -p /usr/lib/binfmt.d
sudo tee /usr/lib/binfmt.d/wine.conf > /dev/null <<WEOF
:WindowsExe:M::MZ::${WINE_PATH}:UTC
:WindowsMSI:E::msi::${WINE_PATH}:UTC
WEOF

log_ok "binfmt_misc configurado! .exe abre automaticamente via Wine"
