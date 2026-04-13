#!/bin/bash
# Lune OS — Aplicador de Temas
# Aplica qualquer tema em: Hyprland, Waybar, Rofi, Kitty, Hyprlock

GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[TEMA]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[TEMA]${NC} $1"; }

THEMES_DIR="$HOME/lune-os/themes"
CONFIG="$HOME/.config"
LUNE_CONFIG="$HOME/.config/lune"

# ── Listar temas disponíveis ─────────────────────────────────
list_themes() {
  echo -e "\n${PURPLE}🌙 Temas disponíveis:${NC}\n"
  echo "  1) 🌙 Lune Dark       — padrão, fundo escuro com lilás"
  echo "  2) 🌸 Lune Light      — claro e elegante"
  echo "  3) 🌿 Lune Aurora     — verde aurora boreal"
  echo "  4) 🌅 Lune Sunset     — laranja e rosa pôr do sol"
  echo "  5) 🌊 Lune Ocean      — azul oceano profundo"
  echo "  6) ⬛ Lune Monochrome — preto e branco minimalista"
  echo ""
}

# ── Carregar tema ────────────────────────────────────────────
load_theme() {
  local theme_file="$THEMES_DIR/$1/theme.conf"
  
  if [ ! -f "$theme_file" ]; then
    echo "Tema não encontrado: $1"
    exit 1
  fi

  # Ler cores do tema
  BG=$(grep "^background " "$theme_file" | cut -d= -f2 | tr -d ' ')
  BG_ALT=$(grep "^background_alt" "$theme_file" | cut -d= -f2 | tr -d ' ')
  SURFACE=$(grep "^surface " "$theme_file" | cut -d= -f2 | tr -d ' ')
  FG=$(grep "^foreground " "$theme_file" | cut -d= -f2 | tr -d ' ')
  FG_DIM=$(grep "^foreground_dim" "$theme_file" | cut -d= -f2 | tr -d ' ')
  PRIMARY=$(grep "^primary " "$theme_file" | cut -d= -f2 | tr -d ' ')
  PRIMARY_DIM=$(grep "^primary_dim" "$theme_file" | cut -d= -f2 | tr -d ' ')
  SECONDARY=$(grep "^secondary " "$theme_file" | cut -d= -f2 | tr -d ' ')
  BORDER=$(grep "^border_active" "$theme_file" | cut -d= -f2 | tr -d ' ')
  BORDER_INACTIVE=$(grep "^border_inactive" "$theme_file" | cut -d= -f2 | tr -d ' ')
  BORDER1=$(echo $BORDER | cut -d, -f1)
  BORDER2=$(echo $BORDER | cut -d, -f2)
  ERROR=$(grep "^error" "$theme_file" | cut -d= -f2 | tr -d ' ')
  WARNING=$(grep "^warning" "$theme_file" | cut -d= -f2 | tr -d ' ')
}

# ── Aplicar no Hyprland ──────────────────────────────────────
apply_hyprland() {
  log_info "Aplicando no Hyprland..."

  # Converter hex para rgba (remove #)
  local p1=$(echo $BORDER1 | tr -d '#')
  local p2=$(echo $BORDER2 | tr -d '#')
  local bi=$(echo $BORDER_INACTIVE | tr -d '#')

  # Atualizar cores via hyprctl se estiver rodando
  if command -v hyprctl &>/dev/null && hyprctl version &>/dev/null 2>&1; then
    hyprctl keyword "general:col.active_border" "rgba(${p1}ff) rgba(${p2}ff) 45deg" 2>/dev/null || true
    hyprctl keyword "general:col.inactive_border" "rgba(${bi}ff)" 2>/dev/null || true
    log_ok "Hyprland atualizado em tempo real"
  fi

  # Salvar nas variáveis de ambiente do Lune
  mkdir -p "$LUNE_CONFIG"
  cat > "$LUNE_CONFIG/current-theme.env" << ENVEOF
LUNE_BG=$BG
LUNE_BG_ALT=$BG_ALT
LUNE_SURFACE=$SURFACE
LUNE_FG=$FG
LUNE_FG_DIM=$FG_DIM
LUNE_PRIMARY=$PRIMARY
LUNE_PRIMARY_DIM=$PRIMARY_DIM
LUNE_SECONDARY=$SECONDARY
LUNE_BORDER1=$BORDER1
LUNE_BORDER2=$BORDER2
LUNE_ERROR=$ERROR
LUNE_WARNING=$WARNING
ENVEOF
}

# ── Aplicar no Waybar ────────────────────────────────────────
apply_waybar() {
  log_info "Aplicando no Waybar..."

  local waybar_colors="$CONFIG/waybar/colors.css"
  mkdir -p "$CONFIG/waybar"

  # Converter hex para rgb
  hex_to_rgb() {
    local hex=$(echo $1 | tr -d '#')
    printf "%d, %d, %d" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
  }

  cat > "$waybar_colors" << CSSEOF
/* Lune OS — Cores do tema atual */
/* Gerado automaticamente por apply-theme.sh */
:root {
  --bg:         $BG;
  --bg-alt:     $BG_ALT;
  --surface:    $SURFACE;
  --fg:         $FG;
  --fg-dim:     $FG_DIM;
  --primary:    $PRIMARY;
  --primary-dim: $PRIMARY_DIM;
  --secondary:  $SECONDARY;
  --border:     $BORDER1;
  --error:      $ERROR;
  --warning:    $WARNING;
}
CSSEOF

  # Recarregar Waybar se estiver rodando
  pkill -SIGUSR2 waybar 2>/dev/null && log_ok "Waybar recarregado" || true
}

# ── Aplicar no Kitty ─────────────────────────────────────────
apply_kitty() {
  log_info "Aplicando no Kitty..."

  local kitty_theme="$CONFIG/kitty/current-theme.conf"
  mkdir -p "$CONFIG/kitty"

  cat > "$kitty_theme" << KITTYEOF
# Lune OS — Tema atual do Kitty
background            $BG
foreground            $FG
cursor                $PRIMARY
cursor_text_color     $BG
selection_background  $PRIMARY
selection_foreground  $BG

# Cores básicas
color0   $BG_ALT
color1   $ERROR
color2   #6FD08C
color3   $WARNING
color4   $SECONDARY
color5   $PRIMARY
color6   $SECONDARY
color7   $FG
color8   $SURFACE
color9   $ERROR
color10  #6FD08C
color11  $WARNING
color12  $SECONDARY
color13  $PRIMARY
color14  $SECONDARY
color15  $FG
KITTYEOF

  # Recarregar Kitty se estiver rodando
  pkill -SIGUSR1 kitty 2>/dev/null || true
  log_ok "Kitty atualizado"
}

# ── Salvar tema atual ────────────────────────────────────────
save_current_theme() {
  mkdir -p "$LUNE_CONFIG"
  echo "LUNE_THEME=$THEME_NAME" > "$LUNE_CONFIG/current-theme.conf"
  log_ok "Tema '$THEME_NAME' salvo como padrão"
}

# ── Main ─────────────────────────────────────────────────────
main() {
  # Se passou argumento, usa direto
  if [ -n "$1" ]; then
    THEME_NAME="$1"
  else
    list_themes
    read -rp "Escolha [1-6]: " choice
    case "$choice" in
      1) THEME_NAME="lune-dark" ;;
      2) THEME_NAME="lune-light" ;;
      3) THEME_NAME="lune-aurora" ;;
      4) THEME_NAME="lune-sunset" ;;
      5) THEME_NAME="lune-ocean" ;;
      6) THEME_NAME="lune-monochrome" ;;
      *) THEME_NAME="lune-dark" ;;
    esac
  fi

  echo -e "\n${CYAN}Aplicando tema: $THEME_NAME${NC}\n"

  load_theme "$THEME_NAME"
  apply_hyprland
  apply_waybar
  apply_kitty
  save_current_theme

  echo ""
  echo -e "${GREEN}✅ Tema $THEME_NAME aplicado em tudo!${NC}"
  echo -e "${PURPLE}🌙 Your world, just lighter.${NC}"
}

main "$@"
