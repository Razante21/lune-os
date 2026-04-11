#!/bin/bash
# Lune OS — Tweaks de Performance
# Aplica otimizações de kernel, memória e I/O para uso desktop

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[PERF]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[PERF]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[PERF]${NC} $1"; }

# ── Tweaks de memória e swap ─────────────────────────────────
apply_memory_tweaks() {
  log_info "Aplicando tweaks de memória..."

  sudo tee /etc/sysctl.d/99-lune-performance.conf > /dev/null <<EOF
# Lune OS — Tweaks de Performance
# Gerado automaticamente pelo script performance.sh

# ── Memória ──────────────────────────────────────────────────
# Reduz uso de swap — RAM é priorizada
vm.swappiness = 10

# Mais cache de filesystem em memória
vm.vfs_cache_pressure = 50

# Permite mais memória "suja" antes de escrever em disco
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# Tamanho mínimo de memória livre mantida pelo kernel
vm.min_free_kbytes = 65536

# ── CPU e scheduler ──────────────────────────────────────────
# Reduz latência de despertar de processos interativos
kernel.sched_latency_ns = 4000000
kernel.sched_min_granularity_ns = 500000
kernel.sched_wakeup_granularity_ns = 25000

# Permite mais processos em background sem afetar interatividade
kernel.sched_migration_cost_ns = 500000

# ── Rede ─────────────────────────────────────────────────────
# Buffers maiores para melhor throughput de rede
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216

# Reduz tempo de espera em conexões TCP
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300

# ── Sistema de arquivos ───────────────────────────────────────
# Aumenta limite de arquivos abertos simultaneamente
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288

# ── Segurança ─────────────────────────────────────────────────
# Protege contra ataques de buffer
kernel.randomize_va_space = 2
EOF

  # Aplicar imediatamente sem reiniciar
  sudo sysctl --system > /dev/null 2>&1
  log_ok "Tweaks de memória aplicados"
}

# ── Configurar I/O Scheduler ─────────────────────────────────
configure_io_scheduler() {
  log_info "Configurando I/O scheduler..."

  # Detectar tipo de disco (SSD ou HDD)
  for DISK in /sys/block/sd* /sys/block/nvme* /sys/block/vd*; do
    [ -d "$DISK" ] || continue

    DISK_NAME=$(basename "$DISK")
    ROTATIONAL=$(cat "$DISK/queue/rotational" 2>/dev/null || echo "1")

    if [ "$ROTATIONAL" = "0" ]; then
      # SSD / NVMe — usar none (sem overhead de scheduler)
      SCHEDULER="none"
      log_info "$DISK_NAME: SSD detectado → scheduler: none"
    else
      # HDD — usar bfq (melhor latência para uso interativo)
      SCHEDULER="bfq"
      log_info "$DISK_NAME: HDD detectado → scheduler: bfq"
    fi

    # Aplicar imediatamente
    echo "$SCHEDULER" | sudo tee "$DISK/queue/scheduler" > /dev/null 2>&1 || true
  done

  # Persistir via udev rules
  sudo tee /etc/udev/rules.d/60-lune-io-scheduler.rules > /dev/null <<'EOF'
# Lune OS — I/O Scheduler otimizado
# SSD e NVMe: sem scheduler (acesso direto)
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
# HDD: bfq (baixa latência interativa)
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

  log_ok "I/O scheduler configurado"
}

# ── Configurar CPU governor ──────────────────────────────────
configure_cpu_governor() {
  log_info "Configurando CPU governor..."

  # Verificar se cpupower está disponível
  if command -v cpupower &>/dev/null; then
    # schedutil: responsivo e eficiente para desktop
    sudo cpupower frequency-set -g schedutil > /dev/null 2>&1 || \
      log_warn "Não foi possível configurar o governor via cpupower"
  fi

  # Configurar via sysfs como fallback
  for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$CPU" ] || continue
    echo "schedutil" | sudo tee "$CPU" > /dev/null 2>&1 || true
  done

  log_ok "CPU governor: schedutil (dinâmico e responsivo)"
}

# ── Otimizar Btrfs ───────────────────────────────────────────
optimize_btrfs() {
  log_info "Verificando e otimizando Btrfs..."

  # Verificar se sistema de arquivos é Btrfs
  if ! findmnt -t btrfs / > /dev/null 2>&1; then
    log_warn "Sistema não está em Btrfs — pulando otimizações de Btrfs"
    return
  fi

  # Adicionar opções de montagem recomendadas
  # noatime: não atualiza tempo de acesso (reduz escritas)
  # compress=zstd: compressão eficiente
  # space_cache=v2: cache de espaço mais moderno
  if ! grep -q "noatime" /etc/fstab; then
    log_info "Adicionando opções de montagem Btrfs ao fstab..."
    sudo sed -i 's/\(.*btrfs.*defaults\)/\1,noatime,compress=zstd:1,space_cache=v2/' /etc/fstab
  fi

  log_ok "Btrfs otimizado"
}

# ── Desativar serviços desnecessários ────────────────────────
disable_unused_services() {
  log_info "Desativando serviços desnecessários..."

  SERVICES_TO_DISABLE=(
    "systemd-timesyncd"   # Substituído pelo NetworkManager
  )

  for SERVICE in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled "$SERVICE" &>/dev/null; then
      sudo systemctl disable --now "$SERVICE" 2>/dev/null || true
      log_info "Desativado: $SERVICE"
    fi
  done

  log_ok "Serviços otimizados"
}

# ── Configurar zram ──────────────────────────────────────────
setup_zram() {
  log_info "Configurando zram (swap comprimido em RAM)..."

  if ! pacman -Qi zram-generator &>/dev/null; then
    sudo pacman -S --noconfirm --needed zram-generator
  fi

  sudo tee /etc/systemd/zram-generator.conf > /dev/null <<EOF
# Lune OS — Configuração de zram
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
swap-priority = 100
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now systemd-zram-setup@zram0.service 2>/dev/null || true

  log_ok "zram configurado (swap comprimido em RAM, sem disco)"
}

# ── Relatório final ──────────────────────────────────────────
show_report() {
  echo ""
  log_ok "Tweaks de performance aplicados:"
  echo ""
  echo "  vm.swappiness    = $(cat /proc/sys/vm/swappiness)"
  echo "  vm.vfs_cache     = $(cat /proc/sys/vm/vfs_cache_pressure)"

  for DISK in /sys/block/sd* /sys/block/nvme*; do
    [ -d "$DISK" ] || continue
    DISK_NAME=$(basename "$DISK")
    SCHEDULER=$(cat "$DISK/queue/scheduler" 2>/dev/null | grep -oP '\[\K[^\]]+' || echo "desconhecido")
    echo "  I/O ($DISK_NAME)  = $SCHEDULER"
  done
  echo ""
}

# ── Main ─────────────────────────────────────────────────────
main() {
  apply_memory_tweaks
  configure_io_scheduler
  configure_cpu_governor
  optimize_btrfs
  disable_unused_services
  setup_zram
  show_report
}

main "$@"
