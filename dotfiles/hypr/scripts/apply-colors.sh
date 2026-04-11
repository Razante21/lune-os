#!/bin/bash
# Lune OS — Aplicar cores do Wallust em todos os componentes
# Chamado automaticamente ao trocar wallpaper

WAL_COLORS="$HOME/.cache/wal/colors"
WAYBAR_COLORS="$HOME/.config/waybar/colors.css"
ROFI_COLORS="$HOME/.config/rofi/colors.rasi"

[ -f "$WAL_COLORS" ] || exit 0

# Ler cores geradas pelo Wallust
read_color() { sed -n "${1}p" "$WAL_COLORS" | tr -d '#\n'; }

BG=$(read_color 1)
FG=$(read_color 8)
C1=$(read_color 2)
C2=$(read_color 3)
C3=$(read_color 4)
C4=$(read_color 5)
C5=$(read_color 6)

# Atualizar Waybar colors.css
cat > "$WAYBAR_COLORS" << EOF
/* Lune OS — Waybar Colors — gerado pelo Wallust */
@define-color background  rgba($(printf '%d, %d, %d' 0x${BG:0:2} 0x${BG:2:2} 0x${BG:4:2}), 0.65);
@define-color surface     rgba($(printf '%d, %d, %d' 0x${C1:0:2} 0x${C1:2:2} 0x${C1:4:2}), 0.60);
@define-color accent      rgba($(printf '%d, %d, %d' 0x${C4:0:2} 0x${C4:2:2} 0x${C4:4:2}), 1.00);
@define-color accent2     rgba($(printf '%d, %d, %d' 0x${C3:0:2} 0x${C3:2:2} 0x${C3:4:2}), 1.00);
@define-color text        rgba($(printf '%d, %d, %d' 0x${FG:0:2} 0x${FG:2:2} 0x${FG:4:2}), 1.00);
@define-color text-dim    rgba($(printf '%d, %d, %d' 0x${FG:0:2} 0x${FG:2:2} 0x${FG:4:2}), 0.60);
@define-color border      rgba($(printf '%d, %d, %d' 0x${C4:0:2} 0x${C4:2:2} 0x${C4:4:2}), 0.35);
@define-color success     rgba(111, 207, 151, 1);
@define-color warning     rgba(242, 153, 74,  1);
@define-color error       rgba(235, 87,  87,  1);
EOF

# Atualizar Rofi colors.rasi
cat > "$ROFI_COLORS" << EOF
/* Lune OS — Rofi Colors — gerado pelo Wallust */
* {
    background:    rgba($(printf '%d, %d, %d' 0x${BG:0:2} 0x${BG:2:2} 0x${BG:4:2}), 0.85);
    surface:       rgba($(printf '%d, %d, %d' 0x${C1:0:2} 0x${C1:2:2} 0x${C1:4:2}), 0.60);
    surface-hover: rgba($(printf '%d, %d, %d' 0x${C2:0:2} 0x${C2:2:2} 0x${C2:4:2}), 0.60);
    selected:      rgba($(printf '%d, %d, %d' 0x${C4:0:2} 0x${C4:2:2} 0x${C4:4:2}), 0.12);
    border:        rgba($(printf '%d, %d, %d' 0x${C4:0:2} 0x${C4:2:2} 0x${C4:4:2}), 0.35);
    accent:        rgba($(printf '%d, %d, %d' 0x${C4:0:2} 0x${C4:2:2} 0x${C4:4:2}), 1.00);
    foreground:    rgba($(printf '%d, %d, %d' 0x${FG:0:2} 0x${FG:2:2} 0x${FG:4:2}), 1.00);
    text-dim:      rgba($(printf '%d, %d, %d' 0x${FG:0:2} 0x${FG:2:2} 0x${FG:4:2}), 0.60);
}
EOF

# Atualizar bordas das janelas no Hyprland
if command -v hyprctl &>/dev/null; then
    hyprctl keyword general:col.active_border \
        "rgba(${C4}ff) rgba(${C3}ff) 45deg" 2>/dev/null || true
fi

# Recarregar Waybar
pkill -SIGUSR2 waybar 2>/dev/null || true

# Recarregar Swaync
swaync-client --reload-config 2>/dev/null || true

echo "✅ Cores aplicadas com sucesso"
