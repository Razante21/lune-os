#!/bin/bash
# Lune OS — Adaptive Color System
# Troca wallpaper e propaga cores para todo o sistema automaticamente

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[COLOR]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[COLOR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[COLOR]${NC} $1"; }

# ── Paleta fallback do Lune OS ───────────────────────────────
# Usada quando Wallust gera cores inválidas
LUNE_FALLBACK_COLORS=(
  "0D0E14"  # color0  — background
  "1A1B26"  # color1  — surface
  "2E2F3E"  # color2  — midgray
  "C8A8E9"  # color3  — lilac (primary)
  "7EB8F7"  # color4  — blue (secondary)
  "9B7FD4"  # color5  — accent
  "E8E8F0"  # color6  — foreground
  "A0A0B0"  # color7  — muted
  "0D0E14"  # color8  — background dark
  "C8A8E9"  # color9  — lilac bright
  "7EB8F7"  # color10 — blue bright
  "9B7FD4"  # color11 — accent bright
  "E8E8F0"  # color12 — foreground bright
  "C8A8E9"  # color13 — cursor
  "7EB8F7"  # color14 — highlight
  "FFFFFF"  # color15 — white
)

WALLUST_CACHE="$HOME/.cache/wallust"
LUNE_COLORS_FILE="$HOME/.config/lune/colors.conf"
CURRENT_WALLPAPER_FILE="$HOME/.config/lune/current_wallpaper"

# ── Verificar dependências ───────────────────────────────────
check_deps() {
  local missing=()

  command -v wallust &>/dev/null || missing+=("wallust")
  command -v swww    &>/dev/null || missing+=("swww")

  if [ ${#missing[@]} -gt 0 ]; then
    log_warn "Dependências ausentes: ${missing[*]}"
    log_info "Instalando..."
    sudo pacman -S --noconfirm --needed "${missing[@]}" 2>/dev/null || \
      pip3 install pywal --break-system-packages 2>/dev/null || true
  fi
}

# ── Iniciar daemon do swww ───────────────────────────────────
start_swww() {
  if ! pgrep -x "swww-daemon" > /dev/null 2>&1; then
    log_info "Iniciando swww daemon..."
    swww-daemon &
    sleep 1
  fi
}

# ── Aplicar wallpaper com transição suave ────────────────────
apply_wallpaper() {
  local wallpaper="$1"

  if [ ! -f "$wallpaper" ]; then
    log_warn "Wallpaper não encontrado: $wallpaper"
    return 1
  fi

  log_info "Aplicando wallpaper: $(basename "$wallpaper")"

  start_swww

  swww img "$wallpaper" \
    --transition-type fade \
    --transition-duration 0.8 \
    --transition-fps 60 \
    2>/dev/null || \
  swww img "$wallpaper" 2>/dev/null || true

  # Salvar wallpaper atual
  mkdir -p "$(dirname "$CURRENT_WALLPAPER_FILE")"
  echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"

  log_ok "Wallpaper aplicado"
}

# ── Gerar paleta com Wallust ─────────────────────────────────
generate_palette() {
  local wallpaper="$1"

  log_info "Gerando paleta de cores com Wallust..."

  # Rodar Wallust em modo dark com backend haishoku
  wallust run \
    --backend haishoku \
    --colorscheme dark \
    "$wallpaper" 2>/dev/null || \
  # Fallback: pywal
  wal -i "$wallpaper" --backend haishoku -n -q 2>/dev/null || true

  log_ok "Paleta gerada"
}

# ── Verificar qualidade da paleta ────────────────────────────
validate_palette() {
  local colors_file="$HOME/.cache/wal/colors"

  if [ ! -f "$colors_file" ]; then
    log_warn "Paleta não gerada — usando fallback Lune"
    return 1
  fi

  # Verificar se cores são suficientemente escuras (fundo)
  local bg_color
  bg_color=$(head -1 "$colors_file" | tr -d '#' | tr '[:upper:]' '[:lower:]')

  # Converter hex para valor de luminância aproximado
  local r g b
  r=$(echo "$bg_color" | cut -c1-2)
  g=$(echo "$bg_color" | cut -c3-4)
  b=$(echo "$bg_color" | cut -c5-6)

  local r_dec g_dec b_dec
  r_dec=$(printf "%d" "0x$r" 2>/dev/null || echo "128")
  g_dec=$(printf "%d" "0x$g" 2>/dev/null || echo "128")
  b_dec=$(printf "%d" "0x$b" 2>/dev/null || echo "128")

  local luminance=$(( (r_dec * 299 + g_dec * 587 + b_dec * 114) / 1000 ))

  # Se o fundo for muito claro (luminância > 100), usar fallback
  if [ "$luminance" -gt 100 ]; then
    log_warn "Wallpaper muito claro — usando paleta fallback do Lune"
    return 1
  fi

  log_ok "Paleta válida (luminância do fundo: $luminance)"
  return 0
}

# ── Aplicar paleta fallback ──────────────────────────────────
apply_fallback_palette() {
  log_info "Aplicando paleta padrão do Lune OS..."

  mkdir -p "$HOME/.cache/wal"

  # Gerar colors file no formato do pywal
  {
    printf "#%s\n" "${LUNE_FALLBACK_COLORS[0]}"  # background
    for color in "${LUNE_FALLBACK_COLORS[@]}"; do
      printf "#%s\n" "$color"
    done
  } > "$HOME/.cache/wal/colors"

  log_ok "Paleta fallback aplicada"
}

# ── Propagar cores para componentes ─────────────────────────
propagate_colors() {
  log_info "Propagando cores para o sistema..."

  # Waybar — recarregar
  if pgrep -x waybar > /dev/null 2>&1; then
    pkill -SIGUSR2 waybar 2>/dev/null || true
    log_info "Waybar: atualizado"
  fi

  # Kitty — recarregar cores
  if pgrep -x kitty > /dev/null 2>&1; then
    kitty +kitten themes --reload-in=all 2>/dev/null || true
    # Alternativa via pywal
    cat "$HOME/.cache/wal/colors-kitty.conf" > \
      "$HOME/.config/kitty/current-theme.conf" 2>/dev/null || true
    log_info "Kitty: atualizado"
  fi

  # Rofi — usa arquivo de cores gerado automaticamente
  if [ -f "$HOME/.cache/wal/colors-rofi-dark.rasi" ]; then
    cp "$HOME/.cache/wal/colors-rofi-dark.rasi" \
      "$HOME/.config/rofi/colors.rasi" 2>/dev/null || true
    log_info "Rofi: atualizado"
  fi

  # Hyprland — bordas e cores
  if command -v hyprctl &>/dev/null; then
    # Pegar cor primária da paleta
    PRIMARY=$(sed -n '4p' "$HOME/.cache/wal/colors" 2>/dev/null | tr -d '#' || echo "C8A8E9")
    SECONDARY=$(sed -n '5p' "$HOME/.cache/wal/colors" 2>/dev/null | tr -d '#' || echo "7EB8F7")

    hyprctl keyword general:col.active_border "0xFF${PRIMARY} 0xFF${SECONDARY} 45deg" 2>/dev/null || true
    log_info "Hyprland: bordas atualizadas"
  fi

  # Swaync — recarregar
  if pgrep -x swaync > /dev/null 2>&1; then
    swaync-client --reload-config 2>/dev/null || true
    log_info "Swaync: atualizado"
  fi

  # Atualizar SDDM e Hyprlock com novo wallpaper
  local wallpaper
  wallpaper=$(cat "$CURRENT_WALLPAPER_FILE" 2>/dev/null || echo "")

  if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
    # Hyprlock
    if [ -f "$HOME/.config/hyprlock/hyprlock.conf" ]; then
      sed -i "s|path = .*|path = $wallpaper|g" \
        "$HOME/.config/hyprlock/hyprlock.conf" 2>/dev/null || true
      log_info "Hyprlock: wallpaper atualizado"
    fi

    # SDDM
    if [ -d "/usr/share/sddm/themes/lune-sddm" ]; then
      sudo cp "$wallpaper" "/usr/share/sddm/themes/lune-sddm/background.jpg" 2>/dev/null || true
      log_info "SDDM: wallpaper atualizado"
    fi
  fi

  log_ok "Cores propagadas para todo o sistema"
}

# ── Função principal — trocar wallpaper ─────────────────────
change_wallpaper() {
  local wallpaper="$1"

  if [ -z "$wallpaper" ]; then
    # Se não passou wallpaper, abre seletor
    log_info "Nenhum wallpaper especificado"
    log_info "Uso: $0 /caminho/para/wallpaper.jpg"
    log_info "Ou:  $0 --random   (wallpaper aleatório da coleção)"
    return 1
  fi

  check_deps
  apply_wallpaper "$wallpaper"
  generate_palette "$wallpaper"

  if ! validate_palette; then
    apply_fallback_palette
  fi

  propagate_colors

  echo ""
  log_ok "Sistema atualizado com novo wallpaper e cores!"
}

# ── Wallpaper aleatório ──────────────────────────────────────
random_wallpaper() {
  local wallpaper_dirs=(
    "$HOME/.config/lune/wallpapers"
    "$HOME/Pictures/Wallpapers"
    "/usr/share/lune/wallpapers"
  )

  for dir in "${wallpaper_dirs[@]}"; do
    if [ -d "$dir" ]; then
      local wallpaper
      wallpaper=$(find "$dir" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n1)
      if [ -n "$wallpaper" ]; then
        change_wallpaper "$wallpaper"
        return
      fi
    fi
  done

  log_warn "Nenhum diretório de wallpapers encontrado"
}

# ── Configuração inicial ─────────────────────────────────────
setup_wallust() {
  log_info "Configurando Wallust..."

  mkdir -p "$HOME/.config/wallust"

  # Config do Wallust
  cat > "$HOME/.config/wallust/wallust.toml" <<'EOF'
# Lune OS — Configuração do Wallust
backend = "haishoku"
color_space = "lab"
palette = "dark16"

[palette_style]
dark = true
light = false
EOF

  log_ok "Wallust configurado"
}

# ── Main ─────────────────────────────────────────────────────
main() {
  case "${1:-}" in
    --random)
      random_wallpaper
      ;;
    --setup)
      setup_wallust
      ;;
    --help|-h)
      echo "Uso: $0 <wallpaper.jpg>    — Aplica wallpaper específico"
      echo "     $0 --random           — Wallpaper aleatório da coleção"
      echo "     $0 --setup            — Configuração inicial do Wallust"
      ;;
    "")
      setup_wallust
      log_ok "Wallust configurado. Use '$0 /caminho/wallpaper.jpg' para trocar."
      ;;
    *)
      change_wallpaper "$1"
      ;;
  esac
}

main "$@"
