#!/bin/bash
# Lune OS — Corrige configs do Hyprland para versão atual

CONFIG="$HOME/.config/hypr"

# animations.conf
cat > "$CONFIG/conf/animations.conf" << 'EOF'
animations {
    enabled = true
    bezier = easeOutExpo, 0.16, 1, 0.3, 1
    bezier = easeOutBack, 0.34, 1.56, 0.64, 1
    bezier = linear, 0, 0, 1, 1
    bezier = easeInOut, 0.45, 0, 0.55, 1
    animation = windowsIn,   1, 3, easeOutBack,  slide
    animation = windowsOut,  1, 2, easeInOut,    fade
    animation = windowsMove, 1, 3, easeOutExpo,  slide
    animation = fade,        1, 2, easeOutExpo
    animation = workspaces,  1, 4, easeOutExpo,  slide
    animation = borderangle, 1, 8, linear,       loop
    animation = layers,      1, 3, easeOutExpo,  slide
}
EOF

# windowrules.conf
cat > "$CONFIG/conf/windowrules.conf" << 'EOF'
windowrule = float,  match:class pavucontrol
windowrule = float,  match:class blueman-manager
windowrule = float,  match:class gnome-calculator
windowrule = float,  match:class file-roller
windowrule = center, match:class pavucontrol
windowrule = center, match:class gnome-calculator
windowrule = opacity 0.95 0.85, match:class kitty
windowrule = workspace 2, match:class google-chrome
windowrule = workspace 4, match:class discord
layerrule = blur on,       match:namespace waybar
layerrule = ignorezero on, match:namespace waybar
layerrule = blur on,       match:namespace rofi
layerrule = ignorezero on, match:namespace rofi
EOF

echo "✅ Configs corrigidos!"