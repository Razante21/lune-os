#!/bin/bash
# Lune OS — Configuração do binfmt_misc
# Faz arquivos .exe e .msi abrirem automaticamente via Wine
# Sem o usuário saber que o Wine existe

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[BINFMT]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[BINFMT]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[BINFMT]${NC} $1"; }
log_error() { echo -e "${RED}[BINFMT]${NC} $1"; exit 1; }

# ── Verificar Wine instalado ─────────────────────────────────
check_wine() {
  log_info "Verificando instalação do Wine..."

  if ! command -v wine &>/dev/null; then
    log_warn "Wine não encontrado. Instalando..."
    sudo pacman -S --noconfirm --needed wine wine-mono
  fi

  WINE_PATH=$(which wine)
  log_ok "Wine encontrado: $WINE_PATH"
}

# ── Habilitar binfmt_misc ────────────────────────────────────
enable_binfmt() {
  log_info "Habilitando módulo binfmt_misc no kernel..."

  # Carregar módulo
  sudo modprobe binfmt_misc 2>/dev/null || true

  # Montar se não estiver montado
  if ! mountpoint -q /proc/sys/fs/binfmt_misc; then
    sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
  fi

  log_ok "binfmt_misc ativo"
}

# ── Registrar .exe no binfmt_misc ────────────────────────────
register_exe() {
  log_info "Registrando .exe no binfmt_misc..."

  WINE_PATH=$(which wine)

  # Formato: :nome:tipo:offset:magic:mask:interpretador:flags
  # Magic bytes do PE (Windows Executable): MZ = 0x4d5a
  EXE_RULE=":WindowsExe:M::MZ::${WINE_PATH}:UTC"
  MSI_RULE=":WindowsMSI:E::msi::${WINE_PATH}:UTC"

  # Registrar .exe
  if [ -f /proc/sys/fs/binfmt_misc/WindowsExe ]; then
    log_info ".exe já registrado, atualizando..."
    echo -1 | sudo tee /proc/sys/fs/binfmt_misc/WindowsExe > /dev/null
  fi
  echo "$EXE_RULE" | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
  log_ok ".exe registrado no binfmt_misc"

  # Registrar .msi
  if [ -f /proc/sys/fs/binfmt_misc/WindowsMSI ]; then
    log_info ".msi já registrado, atualizando..."
    echo -1 | sudo tee /proc/sys/fs/binfmt_misc/WindowsMSI > /dev/null
  fi
  echo "$MSI_RULE" | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
  log_ok ".msi registrado no binfmt_misc"
}

# ── Persistir configuração no boot ──────────────────────────
persist_binfmt() {
  log_info "Configurando persistência no boot via systemd-binfmt..."

  # Criar arquivo de configuração permanente
  sudo mkdir -p /usr/lib/binfmt.d

  WINE_PATH=$(which wine)

  sudo tee /usr/lib/binfmt.d/wine.conf > /dev/null <<EOF
# Lune OS — binfmt_misc para arquivos Windows
# Arquivos .exe e .msi são redirecionados ao Wine automaticamente

# Executáveis Windows (.exe) — magic bytes: MZ
:WindowsExe:M::MZ::${WINE_PATH}:UTC

# Instaladores Windows (.msi) — extensão
:WindowsMSI:E::msi::${WINE_PATH}:UTC
EOF

  # Habilitar serviço do systemd
  sudo systemctl enable systemd-binfmt.service
  sudo systemctl start systemd-binfmt.service

  log_ok "Configuração persistida — ativa em todo boot"
}

# ── Configurar prefixo Wine padrão ──────────────────────────
setup_wine_prefix() {
  log_info "Configurando prefixo Wine padrão..."

  WINE_PREFIX="$HOME/.wine-lune"

  if [ ! -d "$WINE_PREFIX" ]; then
    log_info "Criando prefixo Wine em $WINE_PREFIX..."
    WINEPREFIX="$WINE_PREFIX" WINEARCH=win64 wineboot --init 2>/dev/null || true
  fi

  # Definir variável de ambiente
  if ! grep -q "WINEPREFIX" "$HOME/.config/hypr/conf/environment.conf" 2>/dev/null; then
    mkdir -p "$HOME/.config/hypr/conf"
    echo "env = WINEPREFIX,$WINE_PREFIX" >> "$HOME/.config/hypr/conf/environment.conf"
  fi

  log_ok "Prefixo Wine configurado em $WINE_PREFIX"
}

# ── Verificar funcionamento ──────────────────────────────────
verify_binfmt() {
  log_info "Verificando configuração do binfmt_misc..."

  if [ -f /proc/sys/fs/binfmt_misc/WindowsExe ]; then
    log_ok "Regra .exe ativa:"
    cat /proc/sys/fs/binfmt_misc/WindowsExe | head -3
  else
    log_warn "Regra .exe não encontrada — pode ser necessário reiniciar"
  fi

  if [ -f /proc/sys/fs/binfmt_misc/WindowsMSI ]; then
    log_ok "Regra .msi ativa"
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  check_wine
  enable_binfmt
  register_exe
  persist_binfmt
  setup_wine_prefix
  verify_binfmt

  echo ""
  log_ok "binfmt_misc configurado!"
  log_ok "Arquivos .exe e .msi agora abrem automaticamente via Wine"
  log_info "Reinicie o sistema para garantir persistência completa"
}

main "$@"
