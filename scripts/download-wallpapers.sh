#!/bin/bash
# Lune OS — Download de Wallpapers via API Wallhaven
# Usa a API pública do wallhaven.cc para buscar wallpapers reais
# por tag, qualidade mínima 1920x1080, top rated, SFW

GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[WALLPAPER]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[WALLPAPER]${NC} ✓ $1"; }
log_warn() { echo -e "${YELLOW}[WALLPAPER]${NC} ⚠ $1"; }
log_err()  { echo -e "${RED}[WALLPAPER]${NC} ✗ $1"; }

WALL_DIR="$HOME/.config/lune/wallpapers"
mkdir -p "$WALL_DIR"/{dark,light,aurora,sunset,ocean,monochrome}

# Quantos wallpapers baixar por tema (mínimo 10)
COUNT=${1:-10}

echo -e "${PURPLE}"
echo "  🌙 Lune OS — Wallpapers via API Wallhaven"
echo "  $COUNT wallpapers por tema — SFW, 1920x1080+"
echo -e "${NC}"

# ── Buscar IDs via API wallhaven ──────────────────────────────
# API pública: https://wallhaven.cc/api/v1/search
# Parâmetros:
#   q         = query/tags de busca
#   categories = 110 = anime+geral (sem pessoas), 100 = geral, 010 = anime
#   purity     = 100 = SFW apenas
#   atleast    = resolução mínima
#   sorting    = toplist = mais bem avaliados
#   topRange   = 1y = último ano
#   page       = página de resultados

fetch_wallpapers() {
  local theme="$1"
  local query="$2"
  local categories="${3:-110}"
  local page="${4:-1}"

  log_info "Buscando: $theme ($query)..."

  local api_url="https://wallhaven.cc/api/v1/search"
  local params="q=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")&categories=$categories&purity=100&atleast=1920x1080&sorting=toplist&order=desc&topRange=1y&page=$page"

  local response
  response=$(curl -sL --max-time 15 "$api_url?$params" 2>/dev/null)

  if [ -z "$response" ]; then
    log_warn "API não respondeu para: $theme"
    return 1
  fi

  # Extrair URLs das imagens do JSON
  echo "$response" | python3 -c "
import json, sys

try:
    data = json.load(sys.stdin)
    walls = data.get('data', [])
    urls = []
    for w in walls:
        path = w.get('path', '')
        if path:
            urls.append(path)
    print('\n'.join(urls[:$COUNT]))
except Exception as e:
    sys.exit(1)
" 2>/dev/null
}

# ── Download de uma imagem ────────────────────────────────────
download_wall() {
  local url="$1"
  local dest="$2"
  local name
  name=$(basename "$url")

  [ -f "$dest" ] && { log_ok "Já existe: $name"; return 0; }

  if curl -sL --max-time 60 --retry 2 \
    -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
    -o "$dest" "$url" 2>/dev/null; then

    if file "$dest" 2>/dev/null | grep -qiE "jpeg|png|webp|image"; then
      local size
      size=$(du -sh "$dest" 2>/dev/null | cut -f1)
      log_ok "$name ($size)"
      return 0
    else
      rm -f "$dest"
      log_warn "Arquivo inválido: $name"
      return 1
    fi
  else
    rm -f "$dest"
    log_warn "Falhou download: $name"
    return 1
  fi
}

# ── Processar tema ────────────────────────────────────────────
process_theme() {
  local theme="$1"
  local query="$2"
  local categories="${3:-110}"
  local downloaded=0
  local page=1

  while [ $downloaded -lt $COUNT ]; do
    local urls
    urls=$(fetch_wallpapers "$theme" "$query" "$categories" "$page")

    if [ -z "$urls" ]; then
      log_warn "Sem mais resultados para: $theme"
      break
    fi

    while IFS= read -r url; do
      [ -z "$url" ] && continue
      [ $downloaded -ge $COUNT ] && break

      local ext="${url##*.}"
      local filename="${theme}_$(printf '%02d' $((downloaded + 1))).$ext"
      local dest="$WALL_DIR/$theme/$filename"

      download_wall "$url" "$dest" && ((downloaded++))
      sleep 0.5
    done <<< "$urls"

    ((page++))
    [ $page -gt 5 ] && break
  done

  log_info "Tema $theme: $downloaded/$COUNT baixados"
}

# ── Temas e suas queries ──────────────────────────────────────
# 🌙 Lune Dark — escuro, roxo, azul, espaço, anime noturno
process_theme "dark" \
  "dark purple blue aesthetic anime space" \
  "110"

# 🌸 Lune Light — claro, pastel, minimalista, natureza clara
process_theme "light" \
  "light pastel minimal aesthetic nature" \
  "100"

# 🌿 Lune Aurora — verde, teal, floresta, aurora boreal
process_theme "aurora" \
  "green teal forest aurora borealis nature" \
  "100"

# 🌅 Lune Sunset — laranja, rosa, pôr do sol, anime céu quente
process_theme "sunset" \
  "sunset orange pink sky warm anime" \
  "110"

# 🌊 Lune Ocean — azul, ciano, mar, água, anime
process_theme "ocean" \
  "ocean blue cyan water sea anime" \
  "110"

# ⬛ Lune Monochrome — p&b, cinza, minimalista, arquitetura
process_theme "monochrome" \
  "monochrome black white minimal architecture" \
  "100"

# ── Definir wallpaper padrão ─────────────────────────────────
DEFAULT=$(find "$WALL_DIR/dark" -name "*.jpg" -o -name "*.png" 2>/dev/null | head -1)
if [ -n "$DEFAULT" ]; then
  cp "$DEFAULT" "$WALL_DIR/default.jpg"
  command -v swww &>/dev/null && \
    swww img "$DEFAULT" --transition-type fade --transition-duration 0.8 2>/dev/null || true
  log_ok "Wallpaper padrão definido"
fi

# ── Resumo ───────────────────────────────────────────────────
total=$(find "$WALL_DIR" -name "*.jpg" -o -name "*.png" 2>/dev/null | grep -v "default" | wc -l)

echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ $total wallpapers baixados no total!${NC}"
echo -e "  Pasta: $WALL_DIR"
echo ""
for theme in dark light aurora sunset ocean monochrome; do
  count=$(find "$WALL_DIR/$theme" -name "*.jpg" -o -name "*.png" 2>/dev/null | wc -l)
  echo -e "  $theme: $count wallpapers"
done
echo -e "${PURPLE}  🌙 Your world, just lighter.${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
