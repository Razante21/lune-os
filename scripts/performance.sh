#!/bin/bash
# Lune OS — Tweaks de Performance
# Compatível com: Arch/CachyOS (sistema real) e Ubuntu/Codespaces (testes)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[PERF]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[PERF]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[PERF]${NC} $1"; }

# ── Detectar se é ambiente real ou Codespaces ────────────────
IS_REAL_SYSTEM=false
if command -v pacman &>/dev/null; then
  IS_REAL_SYSTEM=true
fi

# ── Tweaks de memória e swap ─────────────────────────────────
apply_memory_tweaks() {
  log_info "Aplicando tweaks de memória..."

  sudo tee /etc/sysctl.d/99-lune-performance.conf > /dev/null <<EOF
# Lune OS — Tweaks de Performance

# ── Memória ──────────────────────────────────────────────────
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.min_free_kbytes = 65536

# ── CPU e scheduler ──────────────────────────────────────────
kernel.sched_latency_ns = 4000000
kernel.sched_min_granularity_ns = 500000
kernel.sched_wakeup_granularity_ns = 25000
kernel.sched_migration_cost_ns = 500000

# ── Rede ─────────────────────────────────────────────────────
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300

# ── Sistema de arquivos ───────────────────────────────────────
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288

# ── Segurança ─────────────────────────────────────────────────
kernel.randomize_va_space = 2
EOF

  sudo sysctl --system > /dev/null 2>&1 || true
  log_ok "Tweaks de memória aplicados"
}

# ── Configurar I/O Scheduler ─────────────────────────────────
configure_io_scheduler() {
  log_info "Configurando I/O scheduler..."

  for DISK in /sys/block/sd* /sys/block/nvme* /sys/block/vd*; do
    [ -d "$DISK" ] || continue

    DISK_NAME=$(basename "$DISK")
    ROTATIONAL=$(cat "$DISK/queue/rotational" 2>/dev/null || echo "1")

    if [ "$ROTATIONAL" = "0" ]; then
      SCHEDULER="none"
      log_info "$DISK_NAME: SSD detectado → scheduler: none"
    else
      SCHEDULER="bfq"
      log_info "$DISK_NAME: HDD detectado → scheduler: bfq"
    fi

    echo "$SCHEDULER" | sudo tee "$DISK/queue/scheduler" > /dev/null 2>&1 || \
      log_warn "$DISK_NAME: não foi possível alterar scheduler (normal em VM)"
  done

  # ── CORREÇÃO: criar diretório antes de escrever a regra ────
  if [ -d /etc/udev ]; then
    sudo mkdir -p /etc/udev/rules.d
    sudo tee /etc/udev/rules.d/60-lune-io-scheduler.rules > /dev/null <<'EOF'
# Lune OS — I/O Scheduler otimizado
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
    log_ok "Regra udev criada — persistente no boot"
  else
    log_warn "udev não disponível (normal em Codespaces) — regra não persistida"
    log_info "No sistema real, a regra será criada automaticamente"
  fi
}

# ── Configurar CPU governor ──────────────────────────────────
configure_cpu_governor() {
  log_info "Configurando CPU governor..."

  local changed=0
  for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$CPU" ] || continue
    echo "schedutil" | sudo tee "$CPU" > /dev/null 2>&1 && changed=1 || true
  done

  if [ "$changed" = "1" ]; then
    log_ok "CPU governor: schedutil (dinâmico e responsivo)"
  else
    log_warn "CPU governor não alterado (normal em Codespaces/VM)"
    log_info "No sistema real será configurado automaticamente"
  fi
}

# ── Otimizar Btrfs ───────────────────────────────────────────
optimize_btrfs() {
  log_info "Verificando sistema de arquivos..."

  if findmnt -t btrfs / > /dev/null 2>&1; then
    log_info "Btrfs detectado — aplicando otimizações..."
    if ! grep -q "noatime" /etc/fstab 2>/dev/null; then
      log_warn "Adicione manualmente ao /etc/fstab: noatime,compress=zstd:1,space_cache=v2"
    else
      log_ok "Btrfs já otimizado no fstab"
    fi
  else
    log_info "Sistema não usa Btrfs ($(findmnt -n -o FSTYPE / 2>/dev/null || echo 'desconhecido'))"
    log_info "No sistema real o Lune usará Btrfs com otimizações automáticas"
  fi
}

# ── Configurar zram ──────────────────────────────────────────
setup_zram() {
  if ! $IS_REAL_SYSTEM; then
    log_info "Zram: pulando em Codespaces (configurado no sistema real)"
    return
  fi

  log_info "Configurando zram..."

  if ! command -v zramctl &>/dev/null; then
    sudo pacman -S --noconfirm --needed zram-generator 2>/dev/null || true
  fi

  sudo tee /etc/systemd/zram-generator.conf > /dev/null <<EOF
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
swap-priority = 100
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now systemd-zram-setup@zram0.service 2>/dev/null || true
  log_ok "Zram configurado"
}

# ── Relatório final ──────────────────────────────────────────
show_report() {
  echo ""
  log_ok "Tweaks de performance aplicados:"
  echo ""
  echo "  vm.swappiness         = $(cat /proc/sys/vm/swappiness 2>/dev/null || echo 'n/a')"
  echo "  vm.vfs_cache_pressure = $(cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null || echo 'n/a')"
  echo "  fs.inotify.watches    = $(cat /proc/sys/fs/inotify/max_user_watches 2>/dev/null || echo 'n/a')"

  for DISK in /sys/block/sd* /sys/block/nvme*; do
    [ -d "$DISK" ] || continue
    DISK_NAME=$(basename "$DISK")
    SCHEDULER=$(cat "$DISK/queue/scheduler" 2>/dev/null | grep -oP '\[\K[^\]]+' || echo "padrão")
    echo "  I/O ($DISK_NAME)        = $SCHEDULER"
  done
  echo ""

  if ! $IS_REAL_SYSTEM; then
    echo -e "${YELLOW}  ℹ️  Alguns tweaks só têm efeito no sistema real (Arch/CachyOS)${NC}"
    echo ""
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  if $IS_REAL_SYSTEM; then
    log_info "Sistema real detectado (Arch/CachyOS)"
  else
    log_info "Ambiente de desenvolvimento detectado (Codespaces/Ubuntu)"
    log_info "Aplicando tweaks compatíveis..."
  fi

  apply_memory_tweaks
  configure_io_scheduler
  configure_cpu_governor
  optimize_btrfs
  setup_zram
  show_report
}

main "$@"
