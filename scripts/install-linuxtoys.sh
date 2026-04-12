#!/bin/bash
# Lune OS — Instala o LinuxToys do PsyGreg
# Ferramenta complementar para configurações avançadas
# GitHub: https://github.com/psygreg/linuxtoys
# Versão atual: 5.7 (Março 2026)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[LINUXTOYS]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[LINUXTOYS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[LINUXTOYS]${NC} $1"; }

echo ""
echo "🌙 Lune OS — LinuxToys do PsyGreg"
echo "   Ferramentas complementares para Linux"
echo ""

# Verificar se já está instalado
if command -v linuxtoys &>/dev/null; then
    log_ok "LinuxToys já instalado!"
    log_info "Iniciando..."
    linuxtoys
    exit 0
fi

log_info "Instalando LinuxToys via AUR..."

# Verificar se tem yay ou paru
if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
else
    log_warn "Nenhum helper AUR encontrado. Instalando paru..."
    cd /tmp
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    makepkg -si --noconfirm
    cd ~
    AUR_HELPER="paru"
fi

log_info "Usando: $AUR_HELPER"

# Instalar LinuxToys
$AUR_HELPER -S --noconfirm linuxtoys-bin

if command -v linuxtoys &>/dev/null; then
    log_ok "LinuxToys instalado com sucesso!"
    echo ""
    echo "  O LinuxToys oferece:"
    echo "  • Instalação fácil de apps e codecs"
    echo "  • Shader Booster — otimização gráfica para jogos"
    echo "  • Lucidglyph — fontes mais bonitas no Linux"
    echo "  • Drivers e configurações avançadas"
    echo "  • Interface gráfica amigável"
    echo ""
    log_info "Iniciando LinuxToys..."
    linuxtoys
else
    log_warn "Instalação manual necessária:"
    echo ""
    echo "  git clone https://aur.archlinux.org/linuxtoys-bin.git"
    echo "  cd linuxtoys-bin"
    echo "  makepkg -si"
    echo ""
    echo "  Ou visite: https://github.com/psygreg/linuxtoys"
fi
