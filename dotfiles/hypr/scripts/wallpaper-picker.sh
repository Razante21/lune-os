#!/bin/bash
# Lune OS — Wallpaper Picker
# Super+W: escolhe wallpaper e aplica com Adaptive Color System

WALLPAPER_DIRS=(
    "$HOME/.config/lune/wallpapers"
    "$HOME/Imagens/Wallpapers"
    "$HOME/Pictures/Wallpapers"
)

# Encontrar wallpapers disponíveis
WALLPAPERS=()
for dir in "${WALLPAPER_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        while IFS= read -r -d '' file; do
            WALLPAPERS+=("$file")
        done < <(find "$dir" -type f \( -name "*.jpg" -o -name "*.jpeg" \
            -o -name "*.png" -o -name "*.webp" \) -print0 2>/dev/null)
    fi
done

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "🌙 Lune OS" "Nenhum wallpaper encontrado.\nAdicionando wallpapers em ~/Imagens/Wallpapers"
    mkdir -p "$HOME/Imagens/Wallpapers"
    exit 1
fi

# Selecionar usando Rofi com preview
SELECTED=$(printf '%s\n' "${WALLPAPERS[@]}" | \
    rofi -dmenu \
    -theme ~/.config/rofi/lune.rasi \
    -p "🖼 Wallpaper" \
    -show-icons \
    -display-file "")

[ -z "$SELECTED" ] && exit 0

# Aplicar wallpaper e Adaptive Color System
bash ~/.config/hypr/scripts/../../../scripts/wallust.sh "$SELECTED"
