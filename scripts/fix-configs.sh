#!/bin/bash
# Lune OS — Corrige configs do Hyprland para versão 0.53+ / 0.54

CONFIG="$HOME/.config/hypr"
mkdir -p "$CONFIG/conf"

# animations.conf
cat > "$CONFIG/conf/animations.conf" << 'EOF'
animations {
    enabled = true
    bezier = easeOutExpo, 0.16, 1, 0.3, 1
    bezier = easeOutBack, 0.34, 1.56, 0.64, 1
    bezier = linear, 0, 0, 1, 1
    bezier = easeInOut, 0.45, 0, 0.55, 1
    animation = windows,       1, 3, easeOutBack
    animation = windowsIn,     1, 3, easeOutBack,  popin 80%
    animation = windowsOut,    1, 2, easeInOut,    popin 80%
    animation = windowsMove,   1, 3, easeOutExpo
    animation = fade,          1, 2, easeOutExpo
    animation = workspaces,    1, 4, easeOutExpo,  slide
    animation = borderangle,   1, 8, linear,       loop
    animation = layers,        1, 3, easeOutExpo,  slide
}
EOF

# windowrules.conf — sintaxe correta 0.53+
cat > "$CONFIG/conf/windowrules.conf" << 'EOF'
# Windowrules (sintaxe 0.53+: match:class é obrigatório)
windowrule = float,  match:class pavucontrol
windowrule = float,  match:class blueman-manager
windowrule = float,  match:class gnome-calculator
windowrule = float,  match:class file-roller
windowrule = center, match:class pavucontrol
windowrule = center, match:class gnome-calculator
windowrule = opacity 0.95 0.85, match:class kitty
windowrule = workspace 2, match:class google-chrome
windowrule = workspace 4, match:class discord
windowrule = suppressevent maximize, match:class .*

# Layerrules (sintaxe 0.53+: ignore_alpha com underscore e valor obrigatório)
layerrule = blur on,           match:namespace waybar
layerrule = ignore_alpha 0.3,  match:namespace waybar
layerrule = blur on,           match:namespace rofi
layerrule = ignore_alpha 0.3,  match:namespace rofi
layerrule = dimaround on,      match:namespace rofi
EOF

echo "✅ Configs corrigidos para Hyprland 0.53+!"
