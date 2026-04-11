#!/bin/bash
# Lune OS — Sistema de Pastas Igual ao Windows
# Configura xdg-user-dirs com nomes em português idênticos ao Windows Explorer

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[PASTAS]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[PASTAS]${NC} $1"; }

# ── Configurar xdg-user-dirs em português ────────────────────
setup_folders() {
  log_info "Configurando pastas do usuário..."

  # Criar diretório de config
  mkdir -p "$HOME/.config"

  # Configurar xdg-user-dirs com nomes iguais ao Windows
  cat > "$HOME/.config/user-dirs.dirs" <<EOF
# Lune OS — Pastas do Usuário
# Nomes idênticos ao Windows Explorer para facilitar migração

XDG_DESKTOP_DIR="\$HOME/Área de Trabalho"
XDG_DOWNLOAD_DIR="\$HOME/Downloads"
XDG_TEMPLATES_DIR="\$HOME/Modelos"
XDG_PUBLICSHARE_DIR="\$HOME/Público"
XDG_DOCUMENTS_DIR="\$HOME/Documentos"
XDG_MUSIC_DIR="\$HOME/Músicas"
XDG_PICTURES_DIR="\$HOME/Imagens"
XDG_VIDEOS_DIR="\$HOME/Vídeos"
EOF

  # Criar as pastas fisicamente
  local folders=(
    "Área de Trabalho"
    "Downloads"
    "Documentos"
    "Músicas"
    "Imagens"
    "Vídeos"
    "Modelos"
    "Público"
  )

  for folder in "${folders[@]}"; do
    mkdir -p "$HOME/$folder"
    log_info "Criada: ~/$folder"
  done

  # Aplicar configuração
  xdg-user-dirs-update --force 2>/dev/null || true

  log_ok "Pastas configuradas"
}

# ── Configurar favoritos do Nautilus ─────────────────────────
setup_nautilus_bookmarks() {
  log_info "Configurando favoritos do Nautilus..."

  mkdir -p "$HOME/.config/gtk-3.0"

  cat > "$HOME/.config/gtk-3.0/bookmarks" <<EOF
file://$HOME/Área%20de%20Trabalho Área de Trabalho
file://$HOME/Downloads Downloads
file://$HOME/Documentos Documentos
file://$HOME/Imagens Imagens
file://$HOME/Músicas Músicas
file://$HOME/Vídeos Vídeos
EOF

  log_ok "Favoritos do Nautilus configurados"
}

# ── Configurar locale em português ───────────────────────────
setup_locale() {
  log_info "Verificando locale..."

  # Verificar se pt_BR está disponível
  if locale -a 2>/dev/null | grep -q "pt_BR"; then
    log_ok "Locale pt_BR disponível"
  else
    log_info "Gerando locale pt_BR..."
    echo "pt_BR.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen > /dev/null
    sudo locale-gen 2>/dev/null || true
  fi

  # Configurar para o usuário
  if [ ! -f "$HOME/.config/locale.conf" ]; then
    cat > "$HOME/.config/locale.conf" <<EOF
LANG=pt_BR.UTF-8
LC_TIME=pt_BR.UTF-8
LC_NUMERIC=pt_BR.UTF-8
LC_MONETARY=pt_BR.UTF-8
LC_PAPER=pt_BR.UTF-8
LC_ADDRESS=pt_BR.UTF-8
LC_TELEPHONE=pt_BR.UTF-8
LC_MEASUREMENT=pt_BR.UTF-8
EOF
  fi

  log_ok "Locale configurado"
}

# ── Criar pasta "Este Computador" ────────────────────────────
setup_computer_folder() {
  log_info "Configurando acesso rápido ao sistema..."

  # Criar link simbólico para facilitar acesso a discos
  mkdir -p "$HOME/Este Computador"

  # Link para discos montados
  if [ ! -L "$HOME/Este Computador/Disco Principal" ]; then
    ln -sf "/" "$HOME/Este Computador/Disco Principal" 2>/dev/null || true
  fi

  if [ ! -L "$HOME/Este Computador/Mídia" ]; then
    ln -sf "/run/media/$USER" "$HOME/Este Computador/Mídia" 2>/dev/null || true
  fi

  log_ok "'Este Computador' criado em ~/"
}

# ── Configurar Trash igual ao Windows ────────────────────────
setup_trash() {
  log_info "Configurando Lixeira..."

  # A lixeira do Linux (freedesktop) já funciona igual ao Windows
  # Só garantir que o diretório existe
  mkdir -p "$HOME/.local/share/Trash/files"
  mkdir -p "$HOME/.local/share/Trash/info"

  log_ok "Lixeira configurada"
}

# ── Relatório final ──────────────────────────────────────────
show_structure() {
  echo ""
  log_ok "Estrutura de pastas criada:"
  echo ""
  echo "  ~/"
  echo "  ├── Área de Trabalho/    (= Desktop)"
  echo "  ├── Downloads/           (= Downloads)"
  echo "  ├── Documentos/          (= Documents)"
  echo "  ├── Imagens/             (= Pictures)"
  echo "  ├── Músicas/             (= Music)"
  echo "  ├── Vídeos/              (= Videos)"
  echo "  ├── Este Computador/     (= This PC)"
  echo "  └── .local/share/Trash/  (= Recycle Bin)"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────
main() {
  setup_locale
  setup_folders
  setup_nautilus_bookmarks
  setup_computer_folder
  setup_trash
  show_structure
}

main "$@"
