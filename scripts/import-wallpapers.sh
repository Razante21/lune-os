#!/bin/bash
# Lune OS — Importar wallpapers do HD externo
# Detecta automaticamente o HD externo e copia os wallpapers

GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[IMPORT]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[IMPORT]${NC} ✓ $1"; }
log_warn() { echo -e "${YELLOW}[IMPORT]${NC} $1"; }

WALL_DIR="$HOME/.config/lune/wallpapers"
mkdir -p "$WALL_DIR"/{dark,light,aurora,sunset,ocean,monochrome}

echo -e "${PURPLE}"
echo "  🌙 Lune OS — Importar Wallpapers"
echo "  Do HD externo para o sistema"
echo -e "${NC}"

# ── Detectar HD externo ───────────────────────────────────────
log_info "Procurando dispositivos externos montados..."

# Listar dispositivos montados que não são sistema
EXTERNAL_MOUNTS=$(findmnt -rn -o TARGET,SOURCE | grep -v "^/$\|/boot\|/home\|/tmp\|/run\|/sys\|/proc\|/dev" | awk '{print $1}')

if [ -z "$EXTERNAL_MOUNTS" ]; then
  log_warn "Nenhum dispositivo externo encontrado!"
  echo ""
  echo "  Conecte seu HD externo e tente novamente."
  echo "  Ou informe o caminho manualmente:"
  echo ""
  read -rp "  Caminho do HD externo (ex: /run/media/pedro/HD): " MANUAL_PATH
  [ -n "$MANUAL_PATH" ] && EXTERNAL_MOUNTS="$MANUAL_PATH"
fi

# Mostrar opções se múltiplos dispositivos
MOUNT_COUNT=$(echo "$EXTERNAL_MOUNTS" | wc -l)
if [ "$MOUNT_COUNT" -gt 1 ]; then
  echo ""
  echo -e "${BLUE}Dispositivos encontrados:${NC}"
  i=1
  while IFS= read -r mount; do
    echo "  $i) $mount"
    ((i++))
  done <<< "$EXTERNAL_MOUNTS"
  echo ""
  read -rp "Escolha [1-$MOUNT_COUNT]: " choice
  HD_PATH=$(echo "$EXTERNAL_MOUNTS" | sed -n "${choice}p")
else
  HD_PATH="$EXTERNAL_MOUNTS"
fi

if [ ! -d "$HD_PATH" ]; then
  log_warn "Caminho não encontrado: $HD_PATH"
  exit 1
fi

log_ok "HD externo: $HD_PATH"

# ── Buscar wallpapers no HD ───────────────────────────────────
log_info "Procurando imagens no HD..."

# Buscar imagens
IMAGES=$(find "$HD_PATH" -type f \( \
  -iname "*.jpg" -o \
  -iname "*.jpeg" -o \
  -iname "*.png" -o \
  -iname "*.webp" \
\) 2>/dev/null)

IMAGE_COUNT=$(echo "$IMAGES" | grep -c . 2>/dev/null || echo "0")

if [ "$IMAGE_COUNT" -eq 0 ]; then
  log_warn "Nenhuma imagem encontrada em: $HD_PATH"
  exit 1
fi

log_ok "Encontradas $IMAGE_COUNT imagens no HD"

# ── Modo de importação ────────────────────────────────────────
echo ""
echo -e "${BLUE}Como deseja organizar?${NC}"
echo ""
echo "  1) Automático — detectar tema pela cor dominante"
echo "  2) Manual     — você escolhe a pasta de destino"
echo "  3) Tudo no Dark — colocar tudo no tema padrão"
echo ""
read -rp "Escolha [1-3]: " mode

case "$mode" in
  1)
    # Classificação automática por cor dominante usando Python/ImageMagick
    log_info "Classificando por cor dominante..."

    if command -v python3 &>/dev/null && python3 -c "from PIL import Image" 2>/dev/null; then
      # Usar Pillow para análise de cor
      while IFS= read -r img; do
        [ -z "$img" ] && continue

        theme=$(python3 << PYEOF
from PIL import Image
import sys

try:
    img = Image.open("$img").convert("RGB")
    img.thumbnail((100, 100))
    pixels = list(img.getdata())
    avg_r = sum(p[0] for p in pixels) / len(pixels)
    avg_g = sum(p[1] for p in pixels) / len(pixels)
    avg_b = sum(p[2] for p in pixels) / len(pixels)
    brightness = (avg_r + avg_g + avg_b) / 3

    if brightness < 60:
        print("dark")
    elif brightness > 180:
        print("light")
    elif avg_g > avg_r and avg_g > avg_b:
        print("aurora")
    elif avg_r > avg_b and avg_r > avg_g and avg_r > 100:
        print("sunset")
    elif avg_b > avg_r and avg_b > avg_g:
        print("ocean")
    else:
        print("monochrome")
except:
    print("dark")
PYEOF
)

        filename=$(basename "$img")
        dest="$WALL_DIR/$theme/$filename"
        cp "$img" "$dest" 2>/dev/null && log_ok "$filename → $theme"

      done <<< "$IMAGES"

    else
      log_warn "Pillow não instalado — usando modo 'tudo no dark'"
      while IFS= read -r img; do
        [ -z "$img" ] && continue
        filename=$(basename "$img")
        cp "$img" "$WALL_DIR/dark/$filename" 2>/dev/null && log_ok "$filename → dark"
      done <<< "$IMAGES"
    fi
    ;;

  2)
    echo ""
    echo "  Pastas disponíveis:"
    echo "  1) dark   2) light   3) aurora"
    echo "  4) sunset   5) ocean   6) monochrome"
    read -rp "  Destino [1-6]: " dest_choice
    case "$dest_choice" in
      1) DEST_THEME="dark" ;;
      2) DEST_THEME="light" ;;
      3) DEST_THEME="aurora" ;;
      4) DEST_THEME="sunset" ;;
      5) DEST_THEME="ocean" ;;
      6) DEST_THEME="monochrome" ;;
      *) DEST_THEME="dark" ;;
    esac

    log_info "Copiando tudo para: $DEST_THEME"
    while IFS= read -r img; do
      [ -z "$img" ] && continue
      filename=$(basename "$img")
      cp "$img" "$WALL_DIR/$DEST_THEME/$filename" 2>/dev/null && log_ok "$filename"
    done <<< "$IMAGES"
    ;;

  3|*)
    log_info "Copiando tudo para: dark"
    while IFS= read -r img; do
      [ -z "$img" ] && continue
      filename=$(basename "$img")
      cp "$img" "$WALL_DIR/dark/$filename" 2>/dev/null && log_ok "$filename"
    done <<< "$IMAGES"
    ;;
esac

# ── Aplicar primeiro wallpaper ────────────────────────────────
DEFAULT=$(find "$WALL_DIR/dark" -name "*.jpg" -o -name "*.png" 2>/dev/null | head -1)
if [ -n "$DEFAULT" ]; then
  cp "$DEFAULT" "$WALL_DIR/default.jpg"
  command -v swww &>/dev/null && \
    swww img "$DEFAULT" --transition-type fade --transition-duration 0.8 2>/dev/null || true
fi

# ── Resumo ────────────────────────────────────────────────────
total=$(find "$WALL_DIR" -name "*.jpg" -o -name "*.png" -o -name "*.webp" \
  2>/dev/null | grep -v "default" | wc -l)

echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ $total wallpapers importados!${NC}"
for theme in dark light aurora sunset ocean monochrome; do
  count=$(find "$WALL_DIR/$theme" -type f 2>/dev/null | wc -l)
  [ $count -gt 0 ] && echo -e "  $theme: $count wallpapers"
done
echo -e "${PURPLE}  🌙 Your world, just lighter.${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
