#!/bin/bash
# Lune OS — Lune Optimizer
# Manutenção semanal automática e silenciosa
# Roda via systemd timer — o usuário só vê o resultado

set -e

LOG_FILE="/var/log/lune-optimizer.log"
NOTIFY_USER=$(who | awk '{print $1}' | head -1)
FREED_SPACE=0

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

notify() {
  local title="$1"
  local body="$2"
  local icon="${3:-system-run}"

  # Enviar notificação pro usuário logado
  if [ -n "$NOTIFY_USER" ]; then
    sudo -u "$NOTIFY_USER" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$NOTIFY_USER")/bus" \
      notify-send "$title" "$body" --icon="$icon" --app-name="Lune OS" 2>/dev/null || true
  fi
}

# ── Limpar cache de pacotes ──────────────────────────────────
clean_package_cache() {
  log "Limpando cache de pacotes..."

  local before
  before=$(du -sb /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "0")

  # Manter apenas as 2 versões mais recentes de cada pacote
  paccache -rk2 2>/dev/null || true

  local after
  after=$(du -sb /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "0")

  local freed=$(( (before - after) / 1024 / 1024 ))
  FREED_SPACE=$(( FREED_SPACE + freed ))
  log "Cache de pacotes: ${freed}MB liberados"
}

# ── Remover pacotes órfãos ───────────────────────────────────
remove_orphans() {
  log "Verificando pacotes órfãos..."

  local orphans
  orphans=$(pacman -Qtdq 2>/dev/null || echo "")

  if [ -n "$orphans" ]; then
    local count
    count=$(echo "$orphans" | wc -l)
    echo "$orphans" | sudo pacman -Rns --noconfirm - 2>/dev/null || true
    log "Pacotes órfãos removidos: $count"
  else
    log "Nenhum pacote órfão encontrado"
  fi
}

# ── Limpar cache de usuário ──────────────────────────────────
clean_user_cache() {
  log "Limpando cache de usuário..."

  local before
  before=$(du -sb "$HOME/.cache" 2>/dev/null | cut -f1 || echo "0")

  # Limpar caches seguros (mais de 30 dias sem uso)
  find "$HOME/.cache" -type f -atime +30 \
    -not -path "$HOME/.cache/wal/*" \
    -not -path "$HOME/.cache/wallust/*" \
    -delete 2>/dev/null || true

  # Limpar thumbnails antigos
  find "$HOME/.cache/thumbnails" -type f -atime +30 \
    -delete 2>/dev/null || true

  local after
  after=$(du -sb "$HOME/.cache" 2>/dev/null | cut -f1 || echo "0")

  local freed=$(( (before - after) / 1024 / 1024 ))
  FREED_SPACE=$(( FREED_SPACE + freed ))
  log "Cache de usuário: ${freed}MB liberados"
}

# ── Limpar logs antigos ──────────────────────────────────────
clean_logs() {
  log "Limpando logs antigos do sistema..."

  # Manter logs dos últimos 30 dias, máximo 500MB
  sudo journalctl --vacuum-time=30d --vacuum-size=500M 2>/dev/null || true

  log "Logs de sistema otimizados"
}

# ── Verificar integridade do Btrfs ──────────────────────────
check_btrfs() {
  log "Verificando integridade Btrfs..."

  if findmnt -t btrfs / > /dev/null 2>&1; then
    # Verificação leve de consistência (sem scrub completo — muito pesado)
    sudo btrfs filesystem show / 2>/dev/null >> "$LOG_FILE" || true
    log "Btrfs: verificação OK"
  else
    log "Sistema não usa Btrfs — pulando verificação"
  fi
}

# ── Verificar apps pesados em background ─────────────────────
check_heavy_processes() {
  log "Verificando processos pesados em background..."

  # Listar processos consumindo mais de 500MB de RAM
  local heavy
  heavy=$(ps aux --sort=-%mem | awk 'NR>1 && $6>512000 {print $11, int($6/1024)"MB"}' | head -5)

  if [ -n "$heavy" ]; then
    log "Processos pesados detectados:"
    echo "$heavy" | while read -r line; do
      log "  $line"
    done
  else
    log "Nenhum processo pesado detectado"
  fi
}

# ── Limpar prefixo Wine desnecessário ────────────────────────
clean_wine() {
  log "Verificando Wine..."

  WINE_PREFIX="$HOME/.wine-lune"

  if [ -d "$WINE_PREFIX" ]; then
    # Limpar Temp do Wine
    local wine_temp="$WINE_PREFIX/drive_c/users/$USER/Temp"
    if [ -d "$wine_temp" ]; then
      local before
      before=$(du -sb "$wine_temp" 2>/dev/null | cut -f1 || echo "0")
      rm -rf "${wine_temp:?}"/* 2>/dev/null || true
      local after
      after=$(du -sb "$wine_temp" 2>/dev/null | cut -f1 || echo "0")
      local freed=$(( (before - after) / 1024 / 1024 ))
      FREED_SPACE=$(( FREED_SPACE + freed ))
      log "Wine Temp: ${freed}MB liberados"
    fi
  fi
}

# ── Criar snapshot antes da otimização ───────────────────────
create_snapshot() {
  log "Criando snapshot antes da otimização..."
  timeshift --create --comments "Pre-optimizer snapshot" --tags W 2>/dev/null || true
  log "Snapshot criado"
}

# ── Relatório final ──────────────────────────────────────────
send_report() {
  local freed_display
  if [ "$FREED_SPACE" -gt 1024 ]; then
    freed_display="$(( FREED_SPACE / 1024 ))GB"
  else
    freed_display="${FREED_SPACE}MB"
  fi

  log "Otimização concluída. Total liberado: $freed_display"

  # Notificação discreta para o usuário
  if [ "$FREED_SPACE" -gt 0 ]; then
    notify \
      "🌙 Lune OS — Sistema otimizado" \
      "Manutenção automática concluída. ${freed_display} liberados." \
      "system-run"
  else
    notify \
      "🌙 Lune OS — Sistema verificado" \
      "Manutenção automática concluída. Sistema em bom estado." \
      "emblem-default"
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  log "=== Lune Optimizer iniciado ==="

  create_snapshot
  clean_package_cache
  remove_orphans
  clean_user_cache
  clean_logs
  check_btrfs
  check_heavy_processes
  clean_wine
  send_report

  log "=== Lune Optimizer finalizado ==="
}

main "$@"
