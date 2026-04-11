# 🌙 Lune OS

> **Your world, just lighter.**

Lune OS é uma distribuição Linux construída sobre o CachyOS (base Arch) com foco em ser a ponte perfeita para quem migra do Windows. Visual bonito com Hyprland, compatibilidade com `.exe` transparente via Wine + binfmt_misc, e um sistema de cores que se adapta ao wallpaper automaticamente.

---

## ✨ O que é o Lune OS

- **Base:** CachyOS / Arch Linux
- **Compositor:** Hyprland (Wayland)
- **Kernel:** linux-cachyos (scheduler BORE)
- **Sistema de arquivos:** Btrfs com snapshots automáticos
- **Público:** Migrantes do Windows + uso geral
- **Idiomas:** Português Brasileiro (principal) + Inglês

---

## 🚀 Features principais

| Feature | Descrição |
|---|---|
| **binfmt_misc** | Arquivos `.exe` e `.msi` abrem automaticamente via Wine |
| **Adaptive Color System** | Sistema inteiro muda de cor com o wallpaper (via Wallust) |
| **Moonbar** | Três ilhas flutuantes no topo com glassmorphism |
| **Dock switchável** | Dock estilo macOS ou barra estilo Windows |
| **lune-store** | Loja de apps sobre o Flathub |
| **lune-dots** | Aplica dotfiles do GitHub com 1 clique |
| **Lune Assistant** | Sidebar com IA (Gemini API) integrada ao desktop |
| **Lune Sync** | Configurações salvas na nuvem |
| **6 temas visuais** | Dark, Light, Aurora, Sunset, Ocean, Monochrome |
| **120 wallpapers** | 20 por tema, todos validados com o Adaptive Color System |

---

## 📁 Estrutura do Repositório

```
lune-os/
├── dotfiles/                   # Configs do Hyprland, Waybar, Rofi, Kitty
│   ├── hypr/
│   │   ├── conf/               # animations, appearance, keybinds, monitors
│   │   └── scripts/
│   ├── waybar/
│   ├── rofi/
│   ├── kitty/
│   ├── swaync/
│   └── hyprlock/
├── themes/                     # Os 6 temas completos
│   ├── lune-dark/
│   ├── lune-light/
│   ├── lune-aurora/
│   ├── lune-sunset/
│   ├── lune-ocean/
│   └── lune-monochrome/
├── scripts/                    # Scripts de instalação e automação
│   ├── install.sh              # Script principal
│   ├── gpu-detect.sh           # Detecção e instalação de driver GPU
│   ├── binfmt.sh               # Configura .exe automático
│   ├── performance.sh          # Tweaks de kernel e sysctl
│   ├── wallust.sh              # Adaptive Color System
│   ├── folders.sh              # Sistema de pastas igual Windows
│   ├── optimizer.sh            # Lune Optimizer semanal
│   └── update.sh               # Atualização silenciosa
├── installer/                  # Configuração do Calamares
│   ├── calamares/
│   └── branding/
├── wallpapers/                 # Coleção oficial (120 wallpapers)
│   ├── dark/
│   ├── aurora/
│   ├── sunset/
│   ├── ocean/
│   ├── monochrome/
│   └── light/
├── docs/                       # Documentação do projeto
├── .devcontainer/              # Configuração do Codespaces
│   └── devcontainer.json
└── README.md
```

---

## 🛠️ Desenvolvimento

### Pré-requisitos

- Conta GitHub com Codespaces habilitado
- VirtualBox ou VMware para testes visuais do Hyprland
- CachyOS como base para testes em VM

### Ambiente de desenvolvimento

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/lune-os.git
cd lune-os

# Abrir no Codespaces (via GitHub) ou localmente
# O devcontainer configura tudo automaticamente
```

### O que testar onde

| Item | Codespaces | VirtualBox |
|---|---|---|
| Scripts bash | ✅ | ✅ |
| Tweaks de kernel/sysctl | ✅ | ✅ |
| Wallust + paletas | ✅ | ✅ |
| Dotfiles Hyprland visual | ❌ | ✅ |
| Três ilhas + dock | ❌ | ✅ |
| Instalador Calamares | ❌ | ✅ |

---

## 📋 Roadmap

### 🔴 Bloco 1 — Crítico (MVP)
- [ ] Dotfiles Hyprland — três ilhas + dock
- [ ] binfmt_misc — `.exe` abre automaticamente
- [ ] Driver GPU detectado na instalação
- [ ] Btrfs + Timeshift configurados
- [ ] Tweaks de performance
- [ ] Sistema de pastas igual Windows
- [ ] Adaptive Color System via Wallust
- [ ] Impressoras plug and play

### 🟡 Bloco 2 — Importante
- [ ] Instalador Calamares customizado — 5 telas
- [ ] Lune Welcome — personalização no primeiro boot
- [ ] Seleção dos 6 temas na instalação
- [ ] lune-store sobre o Flathub
- [ ] Painel de configurações visual
- [ ] Central de ajuda Super+F1

### 🟢 Bloco 3 — Diferencial
- [ ] Lune Assistant — sidebar IA Gemini
- [ ] lune-dots — dotfiles do GitHub com 1 clique
- [ ] Modo Foco — Super+F
- [ ] Lune Phone Link — integração Android
- [ ] VPN integrada no painel de rede
- [ ] Lune Privacy Dashboard

### 🔵 Bloco 4 — Futuro
- [ ] Lune Sync — configs na nuvem
- [ ] Lune Profiles — perfis de uso
- [ ] Todos os 6 temas completos
- [ ] Open source do código

---

## 📄 Documentação

A documentação completa do projeto está em `docs/`. Cobre arquitetura, design visual, sistema de temas, Adaptive Color System, features exclusivas, atalhos, roadmap e estrutura do repositório.

---

## 🎨 Identidade Visual

- **Paleta padrão:** Lilás `#C8A8E9` + Azul `#7EB8F7` + Fundo `#0D0E14`
- **Fonte:** Inter (UI) + JetBrains Mono (terminal)
- **Logo:** Lua crescente geométrica com glow lilás

---

*Lune OS — Your world, just lighter.*
