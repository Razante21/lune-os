#!/bin/bash
# Lune OS — Script Principal de Instalação
# Roda após a instalação base do CachyOS
# Versão: 0.1.0

set -e

# ── Cores para output ────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Banner ───────────────────────────────────────────────────
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

# ── Funções de log ───────────────────────────────────────────
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()      { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_error()   { echo -e "${RED}[ERRO]${NC} $1"; exit 1; }
log_step()    { echo -e "\n${PURPLE}━━━ $1 ━━━${NC}"; }

pacman_retry() {
  local tries=0
  local max_tries=3

  until [ "$tries" -ge "$max_tries" ]; do
    if "$@"; then
      return 0
    fi

    tries=$((tries + 1))
    log_warn "Falha no pacman (tentativa $tries/$max_tries). Recarregando bases e tentando novamente..."
    sudo pacman -Syy --noconfirm 2>/dev/null || true
  done

  return 1
}

# ── Verificações iniciais ────────────────────────────────────
check_root() {
  if [[ $EUID -eq 0 ]]; then
    log_error "Não execute este script como root. Use seu usuário normal."
  fi
}

check_internet() {
  log_info "Verificando conexão com a internet..."
  if ! ping -c 1 archlinux.org &>/dev/null; then
    log_error "Sem conexão com a internet. Conecte-se e tente novamente."
  fi
  log_ok "Conexão OK"
}

check_cachyos() {
  log_info "Verificando se o sistema é CachyOS..."
  if ! grep -q "CachyOS" /etc/os-release 2>/dev/null; then
    log_warn "Sistema não identificado como CachyOS."
    log_warn "O Lune OS é projetado para CachyOS. Continuar pode causar problemas."
    read -rp "Continuar mesmo assim? [s/N] " confirm
    [[ "$confirm" =~ ^[Ss]$ ]] || exit 0
  else
    log_ok "CachyOS detectado"
  fi
}

# ── Instalação de dependências ───────────────────────────────
install_dependencies() {
  log_step "Instalando dependências base"

  local packages=(
    hyprland
    waybar
    rofi
    kitty
    swaync
    hyprlock
    hypridle
    awww
    wine
    wine-mono
    noto-fonts
    ttf-inter
    ttf-jetbrains-mono-nerd
    nautilus
    file-roller
    vlc
    libreoffice-fresh
    flatpak
    timeshift
    deja-dup
    blueman
    cups
    cups-filters
    network-manager-applet
    wlogout
    grim
    slurp
    cliphist
    wl-clipboard
    polkit-kde-agent
    xdg-desktop-portal-hyprland
    xdg-user-dirs
  )

  log_info "Atualizando sistema..."
  pacman_retry sudo pacman -Syu --noconfirm || \
    log_warn "Falha ao atualizar sistema (mirror/rede). Continuando com o que já está disponível."

  log_info "Instalando pacotes necessários..."
  pacman_retry sudo pacman -S --noconfirm --needed "${packages[@]}" || \
    log_warn "Alguns pacotes podem não ter sido instalados. Verifique manualmente."

  log_ok "Dependências instaladas"
}

# ── Executar sub-scripts ─────────────────────────────────────
run_scripts() {
  local script_dir
  script_dir="$(dirname "$0")"

  log_step "Detectando e instalando driver GPU"
  bash "$script_dir/gpu-detect.sh"

  log_step "Configurando compatibilidade com .exe"
  bash "$script_dir/binfmt.sh"

  log_step "Aplicando otimizações de performance"
  bash "$script_dir/performance.sh"

  log_step "Configurando sistema de pastas"
  bash "$script_dir/folders.sh"

  log_step "Configurando Adaptive Color System"
  bash "$script_dir/wallust.sh"
}

# ── Instalar dotfiles ────────────────────────────────────────
install_dotfiles() {
  log_step "Instalando dotfiles do Lune OS"

  local config_dir="$HOME/.config"
  local dotfiles_dir
  dotfiles_dir="$(dirname "$0")/../dotfiles"

  # Backup dos configs existentes
  if [ -d "$config_dir/hypr" ]; then
    log_info "Fazendo backup dos configs existentes..."
    mv "$config_dir/hypr" "$config_dir/hypr.bkp.$(date +%Y%m%d%H%M%S)"
  fi

  # Copiar dotfiles
  log_info "Aplicando dotfiles do Lune OS..."
  cp -r "$dotfiles_dir/hypr"     "$config_dir/"
  cp -r "$dotfiles_dir/waybar"   "$config_dir/"
  cp -r "$dotfiles_dir/rofi"     "$config_dir/"
  cp -r "$dotfiles_dir/kitty"    "$config_dir/"
  cp -r "$dotfiles_dir/swaync"   "$config_dir/"
  cp -r "$dotfiles_dir/hyprlock" "$config_dir/"

  log_ok "Dotfiles instalados"
}

# ── Configurar Flathub ───────────────────────────────────────
setup_flatpak() {
  log_step "Configurando Flathub"

  flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

  log_info "Instalando apps essenciais via Flatpak..."
  flatpak install -y flathub \
    com.google.Chrome \
    com.discordapp.Discord \
    com.spotify.Client \
    org.telegram.desktop \
    com.obsproject.Studio

  log_ok "Flathub configurado e apps instalados"
}

# ── Configurar Timeshift ─────────────────────────────────────
setup_timeshift() {
  log_step "Configurando Timeshift + Btrfs"

  # Criar config do Timeshift
  sudo mkdir -p /etc/timeshift

  sudo tee /etc/timeshift/timeshift.json > /dev/null <<EOF
{
  "backup_device_uuid": "$(findmnt -n -o UUID /)",
  "parent_device_uuid": "",
  "do_first_run": "false",
  "btrfs_mode": "true",
  "include_btrfs_home_for_backup": "false",
  "include_btrfs_home_for_restore": "false",
  "stop_cron_emails": "true",
  "btrfs_use_qgroup": "true",
  "schedule_monthly": "false",
  "schedule_weekly": "true",
  "schedule_daily": "false",
  "schedule_hourly": "false",
  "schedule_boot": "false",
  "count_monthly": "2",
  "count_weekly": "3",
  "count_daily": "5",
  "count_hourly": "6",
  "count_boot": "5",
  "snapshot_size": "",
  "snapshot_count": "",
  "date_format": "%Y-%m-%d %H:%M:%S",
  "exclude": [],
  "exclude-apps": []
}
EOF

  log_ok "Timeshift configurado com snapshots semanais automáticos"
}

# ── Configurar systemd timers ────────────────────────────────
setup_timers() {
  log_step "Configurando atualizações automáticas silenciosas"

  # Timer de atualização diária
  sudo tee /etc/systemd/system/lune-update.service > /dev/null <<EOF
[Unit]
Description=Lune OS — Atualização Silenciosa
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/lune-update.sh
StandardOutput=journal
StandardError=journal
EOF

  sudo tee /etc/systemd/system/lune-update.timer > /dev/null <<EOF
[Unit]
Description=Lune OS — Timer de Atualização Diária

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

  # Script de atualização
  sudo tee /usr/local/bin/lune-update.sh > /dev/null <<'EOF'
#!/bin/bash
# Cria snapshot antes de atualizar
timeshift --create --comments "Pre-update snapshot" --tags W 2>/dev/null || true
# Atualiza sistema
pacman -Syu --noconfirm 2>/dev/null || true
# Atualiza Flatpaks
flatpak update -y 2>/dev/null || true
EOF

  sudo chmod +x /usr/local/bin/lune-update.sh
  sudo systemctl daemon-reload
  sudo systemctl enable --now lune-update.timer

  log_ok "Timer de atualização silenciosa configurado (03:00 diário)"
}

# ── Configurar SDDM ──────────────────────────────────────────
setup_sddm() {
  log_step "Configurando tela de login SDDM"

  sudo mkdir -p /etc/sddm.conf.d

  sudo tee /etc/sddm.conf.d/lune.conf > /dev/null <<EOF
[Theme]
Current=lune-sddm

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --no-lockscreen
EOF

  sudo systemctl enable sddm
  log_ok "SDDM configurado"
}

# ── Finalização ──────────────────────────────────────────────
finish() {
  log_step "Instalação concluída"

  echo ""
  echo -e "${GREEN}✅ Lune OS instalado com sucesso!${NC}"
  echo ""
  echo -e "${CYAN}Próximos passos:${NC}"
  echo "  1. Reinicie o sistema: sudo reboot"
  echo "  2. Na tela de login, selecione a sessão Hyprland"
  echo "  3. Use Super+Espaço para abrir apps"
  echo "  4. Use Super+F1 para ver todos os atalhos"
  echo "  5. Use Super+W para trocar o wallpaper"
  echo ""
  echo -e "${PURPLE}🌙 Your world, just lighter.${NC}"
  echo ""

  read -rp "Reiniciar agora? [s/N] " reboot_now
  [[ "$reboot_now" =~ ^[Ss]$ ]] && sudo reboot
}

# ── Main ─────────────────────────────────────────────────────
main() {
  banner
  check_root
  check_internet
  check_cachyos
  install_dependencies
  run_scripts
  install_dotfiles
  setup_flatpak
  setup_timeshift
  setup_timers
  setup_sddm
  finish
}

main "$@"
