#!/bin/bash
# Lune OS — Atualização Silenciosa
# Roda às 3h da manhã via systemd timer
# O usuário só é notificado se precisar reiniciar

set -e

LOG_FILE="/var/log/lune-update.log"
NOTIFY_USER=$(who | awk '{print $1}' | head -1)
REBOOT_NEEDED=false

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

pkg_installed() {
  command -v pacman &>/dev/null && pacman -Qq "$1" &>/dev/null
}

detect_mesa_family() {
  if pkg_installed mesa-git; then
    MESA_PKG="mesa-git"
    LIB32_MESA_PKG="lib32-mesa-git"
  else
    MESA_PKG="mesa"
    LIB32_MESA_PKG="lib32-mesa"
  fi
}

using_mesa_git() {
  pkg_installed mesa-git || pkg_installed lib32-mesa-git
}

notify() {
  local title="$1"
  local body="$2"
  [ -n "$NOTIFY_USER" ] || return
  sudo -u "$NOTIFY_USER" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$NOTIFY_USER")/bus" \
    notify-send "$title" "$body" --app-name="Lune OS" 2>/dev/null || true
}

# ── Snapshot antes de atualizar ──────────────────────────────
pre_update_snapshot() {
  log "Criando snapshot pré-atualização..."
  timeshift --create --comments "Pre-update $(date '+%Y-%m-%d')" --tags W \
    2>/dev/null >> "$LOG_FILE" || true
  log "Snapshot criado"
}

# ── Atualizar sistema ────────────────────────────────────────
update_system() {
  log "Atualizando sistema..."

  # Verificar se há atualizações
  local updates
  updates=$(checkupdates 2>/dev/null | wc -l || echo "0")

  if [ "$updates" -eq 0 ]; then
    log "Sistema já está atualizado"
    return 0
  fi

  log "Aplicando $updates atualizações..."

  # Aplicar atualizações
  pacman -Syu --noconfirm 2>/dev/null >> "$LOG_FILE" || {
    log "Erro na atualização — snapshot disponível para rollback"
    return 1
  }

  log "Sistema atualizado com sucesso"

  # Verificar se precisa reiniciar (atualização de kernel)
  if checkupdates 2>/dev/null | grep -q "linux-cachyos\|linux "; then
    REBOOT_NEEDED=true
    log "Reinicialização necessária (kernel atualizado)"
  fi
}

# ── Atualizar Flatpaks ───────────────────────────────────────
update_flatpaks() {
  log "Atualizando Flatpaks..."
  flatpak update -y 2>/dev/null >> "$LOG_FILE" || true
  log "Flatpaks atualizados"
}

# ── Atualizar driver GPU ─────────────────────────────────────
update_gpu_driver() {
  local vendor_file="/etc/lune/gpu-vendor"
  [ -f "$vendor_file" ] || return

  local vendor
  vendor=$(cat "$vendor_file")
  log "Verificando driver GPU ($vendor)..."

  case "$vendor" in
    nvidia)
      if pacman -Qu nvidia-dkms nvidia-utils 2>/dev/null | grep -q .; then
        log "Atualizando driver NVIDIA..."
        pacman -S --noconfirm nvidia-dkms nvidia-utils 2>/dev/null >> "$LOG_FILE" || true
        REBOOT_NEEDED=true
        log "Driver NVIDIA atualizado — reinicialização necessária"
      fi
      ;;
    amd|intel)
      if using_mesa_git; then
        log "mesa-git detectado — pulando atualização automática da pilha Mesa para evitar conflito"
        return 0
      fi
      detect_mesa_family

      if pkg_installed "$MESA_PKG" || pkg_installed "$LIB32_MESA_PKG"; then
        log "Atualizando mesa..."
        pacman -S --noconfirm --needed "$MESA_PKG" "$LIB32_MESA_PKG" 2>/dev/null >> "$LOG_FILE" || true
        log "Mesa atualizado"
      fi
      ;;
  esac
}

# ── Notificar resultado ──────────────────────────────────────
notify_result() {
  if $REBOOT_NEEDED; then
    notify \
      "🌙 Lune OS — Atualização concluída" \
      "Seu sistema foi atualizado. Reinicie quando conveniente para aplicar todas as mudanças."
    log "Usuário notificado sobre reinicialização"
  else
    # Sem reinicialização = silêncio total, o usuário não precisa saber
    log "Atualização silenciosa concluída — sem reinicialização necessária"
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  # Verificar conexão com a internet
  ping -c 1 archlinux.org &>/dev/null || {
    log "Sem internet — atualização cancelada"
    exit 0
  }

  log "=== Lune Update iniciado ==="

  pre_update_snapshot
  update_system
  update_flatpaks
  update_gpu_driver
  notify_result

  log "=== Lune Update finalizado ==="
}

main "$@"
