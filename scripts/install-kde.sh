#!/bin/bash
# Lune OS — Instala KDE Plasma com tema Lune
# Para testar na VM enquanto Hyprland não funciona

GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[KDE]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[KDE]${NC} $1"; }

echo -e "${PURPLE}"
echo "  🌙 Lune OS — KDE Plasma (modo VM)"
echo "  Visual do Lune enquanto Hyprland não funciona em VM"
echo -e "${NC}"

# Instalar KDE Plasma mínimo
log_info "Instalando KDE Plasma..."
sudo pacman -S --noconfirm --needed \
    plasma-desktop \
    plasma-pa \
    plasma-nm \
    dolphin \
    konsole \
    kscreen \
    sddm \
    kde-gtk-config \
    breeze \
    breeze-gtk

# Habilitar SDDM
log_info "Habilitando SDDM..."
sudo systemctl enable sddm

# Aplicar cores do Lune no KDE
log_info "Aplicando paleta de cores Lune..."

mkdir -p ~/.local/share/color-schemes

cat > ~/.local/share/color-schemes/LuneDark.colors << 'COLORS'
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=26,27,38
BackgroundNormal=26,27,38
DecorationFocus=200,168,233
DecorationHover=126,184,247
ForegroundActive=200,168,233
ForegroundInactive=160,160,176
ForegroundLink=126,184,247
ForegroundNegative=235,87,87
ForegroundNeutral=242,153,74
ForegroundNormal=232,232,240
ForegroundPositive=111,207,151
ForegroundVisited=155,127,212

[Colors:Selection]
BackgroundAlternate=155,127,212
BackgroundNormal=200,168,233
DecorationFocus=200,168,233
DecorationHover=126,184,247
ForegroundActive=232,232,240
ForegroundInactive=232,232,240
ForegroundLink=126,184,247
ForegroundNegative=235,87,87
ForegroundNeutral=242,153,74
ForegroundNormal=13,14,20
ForegroundPositive=111,207,151
ForegroundVisited=155,127,212

[Colors:Tooltip]
BackgroundAlternate=26,27,38
BackgroundNormal=13,14,20
DecorationFocus=200,168,233
DecorationHover=126,184,247
ForegroundActive=200,168,233
ForegroundInactive=160,160,176
ForegroundLink=126,184,247
ForegroundNegative=235,87,87
ForegroundNeutral=242,153,74
ForegroundNormal=232,232,240
ForegroundPositive=111,207,151
ForegroundVisited=155,127,212

[Colors:View]
BackgroundAlternate=26,27,38
BackgroundNormal=13,14,20
DecorationFocus=200,168,233
DecorationHover=126,184,247
ForegroundActive=200,168,233
ForegroundInactive=160,160,176
ForegroundLink=126,184,247
ForegroundNegative=235,87,87
ForegroundNeutral=242,153,74
ForegroundNormal=232,232,240
ForegroundPositive=111,207,151
ForegroundVisited=155,127,212

[Colors:Window]
BackgroundAlternate=26,27,38
BackgroundNormal=13,14,20
DecorationFocus=200,168,233
DecorationHover=126,184,247
ForegroundActive=200,168,233
ForegroundInactive=160,160,176
ForegroundLink=126,184,247
ForegroundNegative=235,87,87
ForegroundNeutral=242,153,74
ForegroundNormal=232,232,240
ForegroundPositive=111,207,151
ForegroundVisited=155,127,212

[General]
ColorScheme=LuneDark
Name=Lune Dark
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=13,14,20
activeBlend=200,168,233
activeForeground=200,168,233
inactiveBackground=13,14,20
inactiveBlend=46,47,62
inactiveForeground=160,160,176
COLORS

log_ok "Tema Lune Dark criado para KDE"

echo ""
log_ok "KDE Plasma instalado!"
echo ""
echo "  Reinicie o sistema para entrar no KDE:"
echo "  sudo reboot"
echo ""
echo "  No KDE, aplique o tema Lune Dark em:"
echo "  Configurações → Aparência → Esquema de Cores → Lune Dark"
echo ""
echo "  🌙 Your world, just lighter."
