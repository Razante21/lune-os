# Lune OS — Contexto do Projeto para Claude Code

## O que é

Distribuição Linux baseada em **CachyOS/Arch** com **Hyprland**, focada em facilitar
migração de usuários Windows para Linux. Visual: lilás #C8A8E9 + azul #7EB8F7 + fundo #0D0E14.

- **Repo GitHub:** github.com/Razante21/lune-os (privado)
- **Doc atual:** Lune_Documentacao_v09.docx
- **Versão Hyprland:** 0.54 (CachyOS) — sintaxe 0.53+ obrigatória

---

## Stack técnica

| Camada | Tecnologia |
|--------|-----------|
| Base | CachyOS / Arch Linux |
| Compositor | Hyprland 0.54 |
| Barra | Waybar (3 ilhas glassmorphism) |
| Launcher | Rofi |
| Terminal | Kitty |
| Notificações | Swaync |
| Wallpaper | Swww |
| Cores | Wallust (Adaptive Color System) |
| Login | SDDM (tema QML customizado) |
| Snapshots | Timeshift + Btrfs |
| Windows apps | Wine + binfmt_misc |
| Loja | Flatpak + Flathub |
| IA | Gemini API (Lune Assistant) |

---

## 6 Temas visuais

| Tema | Primária | Secundária |
|------|----------|-----------|
| 🌙 lune-dark | #C8A8E9 | #7EB8F7 |
| 🌸 lune-light | #7B4FA6 | #2E6FBF |
| 🌿 lune-aurora | #88E9B8 | #7ED4F7 |
| 🌅 lune-sunset | #F7A87E | #F77EBF |
| 🌊 lune-ocean | #7ECFF7 | #7EF7E8 |
| ⬛ lune-monochrome | #E0E0E0 | #C0C0C0 |

Aplicar tema: `bash scripts/apply-theme.sh lune-dark`

---

## Sintaxe Hyprland 0.53+ (CRÍTICO)

```ini
# Windowrules — sintaxe nova
windowrule = float on, match:class pavucontrol
windowrule = opacity 0.95 0.85, match:class kitty
windowrule = workspace 2, match:class google-chrome

# Layerrules — sintaxe nova
layerrule = blur on,          match:namespace waybar
layerrule = ignore_alpha 0.3, match:namespace waybar
layerrule = dimaround on,     match:namespace rofi

# Iniciar corretamente
start-hyprland  # em vez de Hyprland

# misc renomeado
misc { on_focus_under_fullscreen = 2 }  # era new_window_takes_over_fullscreen
```

---

## Scripts disponíveis

```
scripts/
  install.sh              — instalador principal (detecta desktop: Hyprland/KDE/GNOME)
  gpu-detect.sh           — detecta GPU + instala drivers (AMD/NVIDIA/Intel)
  performance.sh          — tweaks kernel, I/O, CPU governor, Btrfs, zram
  binfmt.sh               — configura .exe automático via Wine
  folders.sh              — pastas PT-BR idênticas ao Windows
  wallust.sh              — Adaptive Color System via Wallust
  apply-theme.sh          — aplica qualquer dos 6 temas em todo o sistema
  download-wallpapers.sh  — baixa wallpapers via API pública wallhaven.cc
  import-wallpapers.sh    — importa wallpapers do HD externo
  lune-welcome.sh         — tour primeiro boot (4 perguntas via Rofi)
  lune-assistant.sh       — sidebar IA Gemini (Super+A)
  lune-settings.sh        — painel de configurações HTML
  cheat-sheet.sh          — overlay visual de atalhos (segura Super)
  startup-check.sh        — verificação silenciosa no boot
  optimizer.sh            — manutenção semanal silenciosa
  update.sh               — update automático às 3h com snapshot
  setup-sddm.sh           — instala tema login SDDM
  fix-configs.sh          — corrige dotfiles para versão atual Hyprland
  use-vm-config.sh        — config minimalista para VM
  install-kde.sh          — instala KDE com tema Lune
  install-linuxtoys.sh    — instala LinuxToys do PsyGreg (v5.7)
```

---

## Dotfiles

```
dotfiles/
  hypr/
    hyprland.conf         — config principal modular
    hyprland-vm.conf      — config para VM sem GPU
    conf/
      appearance.conf     — bordas, sombras, blur, rounding
      animations.conf     — bezier + animações
      keybinds.conf       — 53 atalhos
      windowrules.conf    — regras janelas/layers (sintaxe 0.53+)
      autostart.conf      — apps que iniciam com Hyprland
      monitors.conf       — detecção automática
      environment.conf    — variáveis Wayland/Qt/GTK/Wine
    scripts/
      apply-colors.sh     — Adaptive Color System
      focus-mode.sh       — Modo Foco (Super+F)
      wallpaper-picker.sh — picker de wallpaper (Super+W)
  waybar/                 — 3 ilhas glassmorphism
  rofi/                   — launcher com tema Lune
  kitty/                  — terminal tema Lune
  swaync/                 — notificações glassmorphism
  hypridle/               — bloqueio automático
  hyprlock/               — tela de bloqueio
installer/
  sddm-theme/             — Main.qml, theme.conf, metadata.desktop
themes/
  lune-dark/theme.conf
  lune-light/theme.conf
  lune-aurora/theme.conf
  lune-sunset/theme.conf
  lune-ocean/theme.conf
  lune-monochrome/theme.conf
```

---

## Status dos testes

| Ambiente | Status | Observação |
|---------|--------|-----------|
| GitHub Codespaces | ✅ OK | Scripts todos testados |
| VirtualBox | ⚠️ Parcial | KDE ok, Hyprland crasha (sem GLES 3.0) |
| QEMU/WSL2 | ⚠️ Parcial | KVM ok, OpenGL não passa pro guest |
| Hardware real | ⏳ Pendente | HD externo 100GB preparado |

**Por que Hyprland não roda em VM:** v0.50+ exige GLES 3.0 mínimo.
A GPU VMware SVGA II e virtio-gpu sem virgl real não suportam isso.

---

## Roadmap

### ✅ Feito (Bloco 1 — Crítico)
- Dotfiles Hyprland 0.53+ completos
- binfmt_misc + Wine
- gpu-detect + performance + folders
- Waybar 3 ilhas + Rofi + Kitty + Swaync
- Hyprlock + Hypridle
- SDDM tema QML
- 6 temas com apply-theme.sh

### ✅ Feito (Bloco 2 — Importante)
- install.sh com escolha Hyprland/KDE/GNOME
- Lune Welcome (primeiro boot)
- Painel de configurações HTML
- LinuxToys integrado

### ✅ Feito (Bloco 3 — Diferencial)
- Lune Assistant (Gemini, Super+A)
- Cheat Sheet visual (segura Super)
- Modo Foco (Super+F)
- download-wallpapers.sh (API wallhaven)
- import-wallpapers.sh (HD externo)

### ⏳ Pendente
- lune-store (sobre Flathub)
- Calamares customizado
- Lune Phone Link (KDE Connect)
- Privacy Dashboard
- VPN integrada
- Lune Sync (nuvem)
- Lune Profiles (perfis de uso)

---

## Referências de dotfiles para inspiração

- **end-4/dots-hyprland** — illogical-impulse, Quickshell, Material Design 3
  - Drag-and-drop de workspaces
  - Circle to Search
  - Screen translation
  - Anti-flashbang
  - Gemini/Ollama integrados
- **dhrruvsharma/shell** — a revisar após quinta-feira
- **ilyamiro/nixos-configuration** — a revisar após quinta-feira
- **Sadrach34/Dotfiles** — animações e muitos wallpapers
- **Reddit:** dotfile com carrossel 3D de wallpapers e leitor de manga/manhwa/novel

> Nota: Usar Waybar agora, migrar pra Quickshell depois se fizer sentido

---

## Sobre o hardware de teste

- **PC:** Ryzen 5 4600G (GPU integrada AMD Vega 7)
- **GPU dedicada:** RTX 5060 (drivers ainda verdes no Linux)
- **Instalação planejada:** Partição dedicada no SSD principal (dual boot com Windows)
- **HD externo:** Transcend 1.8TB — usado para arquivos, NÃO para instalar Linux
- **BIOS:** ASRock — precisa habilitar CSM/Legacy para instalar (HD externo é MBR)
- **Pendrive:** ISO CachyOS gravada com Rufus
- **Plano de teste:** Boot pelo pendrive CachyOS → instalar em partição do SSD principal → clonar repo → bash scripts/install.sh

---

## Modelo Gemini preferido

`gemini-3.1-flash-lite-preview` — sempre usar esse, nunca substituir por outro.

---

## Convenções

- Shell: bash (scripts) / fish (terminal do usuário na VM)
- Heredoc `<< 'EOF'` não funciona no fish — usar arquivos ou python3 para criar
- Pacote da fonte Inter no CachyOS: `inter-font` (não `ttf-inter`)
- timeshift conflita com cachyos-snapper-support — usar `|| true` no install
- CachyOS usa mesa-git — gpu-detect.sh detecta isso e não tenta reinstalar mesa

---

*Documentação v0.9 — Abril 2026 — Em desenvolvimento ativo*
*"Your world, just lighter." 🌙*

---

## Dotfiles de referência — O que tem de interessante

### end-4/dots-hyprland (illogical-impulse)
- https://github.com/end-4/dots-hyprland
- **Quickshell (QML)** como sistema de widgets — barra, sidebars, overlays
- **Material Design 3** com cores dinâmicas geradas pelo wallpaper
- **Drag-and-drop de workspaces** visualmente
- **Circle to Search** — seleciona texto na tela e busca
- **Screen translation** — traduz texto na tela em tempo real
- **Anti-flashbang** — reduz brilho de janelas muito claras
- **Gemini + Ollama** integrados como sidebar sem browser
- **200+ keybindings** com sistema de categorias via comentários `##!`
- **Panel family system** — troca entre "ii" (padrão) e "waffle" (estilo Windows 11)
- Lune OS usa Waybar agora — migrar pra Quickshell é meta futura

### dhrruvsharma/shell
- https://github.com/dhrruvsharma/shell
- A revisar completamente após quinta-feira (13/04/2026)
- Mencionado no Reddit como tendo ideias diferenciadas

### ilyamiro/nixos-configuration
- https://github.com/ilyamiro/nixos-configuration
- A revisar completamente após quinta-feira
- Mencionado junto com ideias diferenciadas

### Sadrach34/Dotfiles
- https://github.com/Sadrach34/Dotfiles
- Hyprland Arch — destaque nas **animações** e **quantidade de wallpapers**
- A revisar para inspiração visual

### Dotfiles vistos no Reddit (sem link ainda — pós 06/05)
- **Carrossel 3D de wallpapers** — picker que aparece em forma de paralelepípedo 3D
- **Leitor de manga/manhwa/novel** integrado no desktop — ideia muito original
- Um outro que causou impacto visual enorme — pendente de link

> Nota pro Claude Code: esses repos precisam ser clonados localmente e analisados
> antes de qualquer implementação. Não tentar acessar URLs diretamente.


---

## ANÁLISE PROFUNDA DOS DOTFILES — Ideias para o Lune OS

### 🔥 liixini/skwd — O PARALELEPÍPEDO QUE VOCÊ VIU
- https://github.com/liixini/skwd
- **ESSE É O DOTFILE DO CARROSSEL PARALELEPÍPEDO** — não é o ilyamiro
- Quickshell (Qt6/QML) — shell completo do zero
- **App Launcher em PARALELEPÍPEDO** — tiles inclinados com splash art, ícones customizados, tags de busca
- **Wallpaper Selector** visual em formato skewed (inclinado)
- **Top Bar** com clock, weather, Wi-Fi, Bluetooth, volume, calendário, music player
  com **letras sincronizadas (lyrics sync)** e visualizador de áudio
- **Window Switcher em paralelepípedo** — mesmo estilo visual
- **Smarthome component** — integração com casa inteligente
- **IA local para análise de wallpapers** — usa Ollama + Gemma3:4b para tagging e ordenação por cor
- **Wallpaper Engine** suportado — papel de parede animado via linux-wallpaperengine
- Configuração granular: naming customizado, icons, search groups, splash art
- Funciona em CachyOS, Arch, Hyprland, Niri, KDE

**O que trazer pro Lune OS:**
- Launcher em paralelepípedo com splash art dos apps
- Window switcher inclinado com thumbnails
- Wallpaper selector com preview visual skewed
- Letras sincronizadas no player de música

---

### 🔥 liixini/skwd-wall — O WALLPAPER SELECTOR QUE VOCÊ VIU
- https://github.com/liixini/skwd-wall
- **Wallpaper selector estético** — imagens, vídeos E Wallpaper Engine Scenes
- Browser integrado do **Wallhaven.cc** com busca, filtros e API key
- Browser integrado do **Steam** para wallpapers do Wallpaper Engine
- **Geração de tema via matugen** a partir do wallpaper selecionado
- **Ordenação por cor** das imagens locais
- **IA local para análise** — Ollama + Gemma3:4b para tagear wallpapers automaticamente
- **Retention de originais** — salva backup antes de converter/comprimir
- **Animações de paralelepípedo** — as tiles inclinadas que você viu no Reddit
- Suporte a vídeo wallpaper via mpvpaper
- Funciona no CachyOS, Arch, Hyprland, Niri, KDE (não funciona no GNOME)

**O que trazer pro Lune OS:**
- Picker de wallpaper com animação de tiles inclinadas (paralelepípedo)
- Browser do Wallhaven integrado com filtros
- Ordenação de wallpapers por cor dominante
- Geração de tema automática ao selecionar wallpaper

---

### 🔥 dhrruvsharma/shell — SHELL COMPLETO EM QML
- https://github.com/dhrruvsharma/shell
- Shell inteiramente em Quickshell/QML — arquitetura de referência
- **Leitor de Manga** (Super+M):
  - Scraping WeebCentral com bypass Cloudflare (curl_cffi + Firefox TLS)
  - Favoritos com detecção automática de novos capítulos (polling 15 min)
  - Download de capítulos para ~/.local/share/quickshell-manga/downloads/
  - Proxy de imagens para bypass CDN
- **Leitor de Anime** (Super+A):
  - AllAnime GraphQL API (mesma fonte do ani-cli)
  - Resolução de links multi-provider
  - Player via MPV
  - Biblioteca em JSON
- **Leitor de Novel** (Super+N):
  - FreeWebNovel como provider
  - Biblioteca persistente
- **Wallhaven Browser** integrado:
  - Suporte completo à API: categorias, purity, sorting, order, top-range, resolução mínima, aspect ratios, query, API key
  - Resultados paginados incrementalmente
  - Download direto + aplicação via setwall + geração de palette
  - Todos os parâmetros persistidos em SettingsConfig
- **Music Player** com letras sincronizadas via Spotify (spotify-lyrics-api local)
- **CAVA Audio Visualizer** togglável no topo e rodapé da tela
- **GitHub Heatmap** — 40 semanas de contribuições no desktop
- **Notes Drawer** — bloco de notas que sobe da parte inferior (zona hover de 900px)
- **Clipboard Manager** visual com histórico
- Configurações persistidas em ~/.cache/quickshell/settings.json com reload automático
- Arquitetura: ShellRoot único, Loader com active:false, deactivation timer 600ms

**O que trazer pro Lune OS:**
- Leitor de manga/manhwa/novel (Bloco 4 — feature exclusiva)
- Player de anime integrado
- Wallhaven browser com todos os filtros
- Letras sincronizadas do Spotify
- CAVA visualizer

---

### ilyamiro/nixos-configuration — 2.8k ⭐
- https://github.com/ilyamiro/nixos-configuration
- Config NixOS + Hyprland declarativo
- Estrutura modular exemplar: animations.nix, binds.nix, window-rules.nix, hypridle.nix, monitors.nix
- Cursores via fetchzip Nix (ArcMidnight)
- Flatpak habilitado por padrão
- Inspiração principal: **organização modular** dos configs
- Também tem versão imperativa: ilyamiro/imperative-dots

**O que trazer pro Lune OS:**
- Estrutura modular de configs — já temos, mas podemos refinar
- A ideia da versão imperativa separada da declarativa

---

### Sadrach34/Dotfiles
- https://github.com/Sadrach34/Dotfiles
- Hyprland Arch — destaque nas **animações fluidas**
- Grande coleção de wallpapers incluída no repo
- Referência principalmente para:
  - Curvas bezier das animações
  - Timings de transição de janelas e workspaces
  - Quantidade e qualidade dos wallpapers incluídos

---

## NOVAS IDEIAS para o Lune OS (extraídas dos dotfiles)

### Bloco 3 — Diferencial (adicionar)
1. **Lune Media Hub** — sidebar com leitor de manga/manhwa + anime + novel
   - Manga: WeebCentral (bypass Cloudflare), favoritos, download
   - Anime: AllAnime GraphQL + MPV
   - Novel: FreeWebNovel
   - Atalho: Super+H (Hub)

2. **Lune Wallpaper Picker** — visual em paralelepípedo/tiles inclinadas
   - Browser Wallhaven integrado com todos os filtros + API key
   - Browser Steam Wallpaper Engine (opcional)
   - Ordenação por cor dominante via IA (Ollama) ou algoritmo
   - Preview em tiles inclinadas estilo skwd
   - Download + aplicação + geração de tema automática

3. **CAVA Visualizer** — barras de áudio no topo/rodapé da tela (togglável via Super+Z)

4. **Letras Sincronizadas** — exibe letra da música atual sincronizada (Spotify)

5. **App Launcher em Paralelepípedo** — tiles inclinadas com splash art dos apps
   - Search por tags customizadas
   - Splash art configurável por app
   - Alternativa visual ao Rofi

6. **Notes Drawer** — bloco de notas que sobe da parte inferior com hover

### Bloco 4 — Futuro (adicionar)
7. **GitHub Heatmap Widget** — 40 semanas de contribuições no desktop
8. **Smarthome Integration** — integração com dispositivos IoT
9. **Wallpaper Engine** — wallpapers animados via linux-wallpaperengine
10. **IA para análise de wallpapers** — Ollama local para tagear e ordenar por cor

---

## Quickshell — Referência técnica

**Por que migrar de Waybar para Quickshell:**
- Waybar: JSON + CSS — simples mas limitado
- Quickshell: QML (Qt6) — qualquer widget imaginável
- Todas as features acima (manga, anime, paralelepípedo, visualizer, letras) só são possíveis no Quickshell
- Performance superior — componentes carregados sob demanda
- IPC nativo com Hyprland

**Packages necessários para Quickshell no CachyOS:**
```bash
# Essenciais
yay -S quickshell-git

# Para dhrruvsharma/shell completo
sudo pacman -S curl jq sqlite ffmpeg imagemagick inotify-tools qt6-multimedia
yay -S awww-bin matugen-bin ttf-material-design-icons-desktop-git

# Opcional (anime/manga/novel)
pip install curl_cffi requests  # Python backends

# Opcional (wallpaper engine)
sudo pacman -S mpvpaper
yay -S steamcmd linux-wallpaperengine-git

# Opcional (IA local)
sudo pacman -S ollama
```

**Roadmap de migração Waybar → Quickshell:**
1. Fase atual: Waybar com 3 ilhas (funcional)
2. Transição: Quickshell com layout similar ao Waybar atual
3. Evolução: adicionar features exclusivas do Quickshell progressivamente
4. Target: shell completo estilo dhrruvsharma/shell mas com identidade Lune

*Nota: Migração não é urgente — Waybar funciona muito bem. Quickshell é meta de longo prazo.*


---

## Como funciona o browser de wallpaper nos dotfiles

**Sim, usa internet fi!** O fluxo é:

```
Super+W → abre o picker
        ↓
Digita busca ou filtra (categoria, purity, resolução, etc)
        ↓
Shell chama API do wallhaven.cc com os parâmetros
        ↓
Imagens aparecem em tiles (paralelepípedo no skwd)
        ↓
Você clica num wallpaper
        ↓
Shell baixa pra ~/Pictures/wallpapers/
        ↓
Aplica via swww + gera tema de cores via matugen/wallust
```

Para wallpapers locais (HD externo, pasta própria):
- O picker mostra thumbnails das imagens locais também
- Ordenação por cor dominante (skwd-wall tem isso)
- Sem internet necessária pra usar os locais

---

## Repo de wallpapers curados para puxar no Lune OS

O **mylinuxforwork/wallpaper** é um repo dedicado só de wallpapers 
curados para Hyprland — pode ser usado como fonte no install.sh:
- https://github.com/mylinuxforwork/wallpaper
- Wallpapers de alta qualidade, curados especificamente para Hyprland
- Pode clonar só a pasta de wallpapers sem instalar o ML4W inteiro

**Script para puxar wallpapers do ML4W no install.sh:**
```bash
# Clonar só os wallpapers (shallow clone)
git clone --depth=1 --filter=blob:none --sparse \
  https://github.com/mylinuxforwork/wallpaper.git /tmp/ml4w-walls
cd /tmp/ml4w-walls
git sparse-checkout set wallpaper
cp wallpaper/* ~/.config/lune/wallpapers/dark/
```

**Sadrach34/Dotfiles** — tem 200+ wallpapers incluídos direto no repo:
- https://github.com/Sadrach34/Dotfiles
- Referência para animações e coleção de wallpapers
- A analisar em detalhe — pode puxar a pasta wallpapers diretamente


---

## Wallpapers — Fonte principal confirmada

**Sadrach34/Dotfiles** tem 200+ wallpapers de qualidade incluídos no repo.
- Clone: `git clone --depth=1 https://github.com/Sadrach34/Dotfiles.git`
- Copiar wallpapers para `lune-os/wallpapers/` organizando por tema
- Já adicionados ao repo do Lune OS via commit manual

**Script para puxar wallpapers do Sadrach34 no install.sh:**
```bash
# Clonar só os wallpapers (sem histórico)
git clone --depth=1 --filter=blob:none --sparse \
  https://github.com/Sadrach34/Dotfiles.git /tmp/sadrach-dots
cd /tmp/sadrach-dots
# Verificar onde estão os wallpapers
find . -name "*.jpg" -o -name "*.png" | head -5
# Copiar pro Lune OS
cp -r wallpapers/* ~/.config/lune/wallpapers/dark/
```


---

## Sadrach34/Dotfiles — O que sabemos
- https://github.com/Sadrach34/Dotfiles
- Repo pessoal com 50 commits — Hyprland Arch
- O GitHub bloqueia acesso direto ao conteúdo via robots.txt
- Pedro viu no repo: **animações muito fluidas** e **grande quantidade de wallpapers**
- Referência principal para: curvas bezier, timings de animação, coleção de wallpapers
- **TODO no Claude Code:** clonar localmente e analisar com `ls -la` e `cat README.md`
  ```bash
  git clone https://github.com/Sadrach34/Dotfiles.git /tmp/sadrach-dots
  ls /tmp/sadrach-dots
  cat /tmp/sadrach-dots/README.md
  # Ver animações
  cat /tmp/sadrach-dots/.config/hypr/conf/animations.conf 2>/dev/null || \
  find /tmp/sadrach-dots -name "animations*" -o -name "animation*" | head -10
  # Contar e listar wallpapers
  find /tmp/sadrach-dots -name "*.jpg" -o -name "*.png" -o -name "*.webp" | wc -l
  ```

---

## Skills recomendadas para o Claude Code

### Para desenvolvimento do Lune OS:

**`/memory` — configurar com:**
```
Projeto: Lune OS — distro Linux Hyprland baseada em CachyOS
Repo: github.com/Razante21/lune-os (privado)
Stack: Hyprland 0.54, Waybar, Rofi, Kitty, Swaync, Swww, Wallust
Sintaxe Hyprland 0.53+: sempre match:class, nunca regex puro; layerrule com ignore_alpha
Shell usuário: fish (heredoc << EOF não funciona no fish — usar python3 ou arquivos)
Gemini: sempre gemini-3.1-flash-lite-preview
Pacote fonte Inter: inter-font (não ttf-inter)
timeshift conflita com cachyos-snapper-support — usar || true
CachyOS usa mesa-git — não tentar reinstalar mesa normal
Iniciar Hyprland: start-hyprland (não Hyprland)
Cores principais: lilás #C8A8E9, azul #7EB8F7, fundo #0D0E14
```

**Superpowers plugin** — instalar no VS Code para o Claude Code ter:
- Memória expandida entre sessões
- Busca web integrada
- Ferramentas extras de contexto

**Primeira mensagem no Claude Code:**
```
Leia o CONTEXT.md e me diga o que entendeu sobre o projeto antes de começar.
```

---

## Próximos passos prioritários (pós quinta-feira 17/04)

### Imediato — hardware real
1. Habilitar CSM na BIOS ASRock (Advanced → CSM → Enabled)
2. Instalar CachyOS na partição do SSD principal (dual boot)
3. Clonar repo: `git clone https://github.com/Razante21/lune-os.git`
4. Rodar: `bash scripts/install.sh` → escolher Hyprland
5. Ver o Lune OS funcionando de verdade na AMD Vega 7

### Desenvolvimento — Claude Code
1. Analisar Sadrach34/Dotfiles localmente (animações + wallpapers)
2. Refinar animations.conf com bezier mais fluidas
3. Implementar Lune Wallpaper Picker em paralelepípedo (inspirado no skwd)
4. Migração progressiva Waybar → Quickshell (começa pelo bar)
5. Leitor de manga/manhwa (inspirado no dhrruvsharma/shell)
6. Lune Store sobre Flathub
7. Calamares customizado

### Dotfiles a analisar depois do dia 06/05
- O dotfile do Reddit que causou impacto visual (link pendente)

---

## Observações finais

- **Versão atual da doc:** Lune_Documentacao_v09.docx
- **Próxima versão:** v1.0 quando Pedro testar no hardware real e aprovar
- **Status geral:** sistema bem estruturado, pronto para teste em hardware real
- **Bloqueio atual:** Hyprland não roda em VM (exige GLES 3.0, GPU virtual não suporta)
- **Solução:** dual boot no SSD principal com partição dedicada

*CONTEXT.md versão final — Abril 2026*
*"Your world, just lighter." 🌙*
*Gerado a partir de sessão de desenvolvimento com Pedro — lune-os/Razante21*

---

## Sadrach34/Dotfiles — O que foi possível identificar
- https://github.com/Sadrach34/Dotfiles
- Repo pessoal pequeno (3 stars, 50 commits) — "Dotfiles from hyprland Arch"
- GitHub bloqueia acesso ao conteúdo via robots.txt
- O que você falou diretamente: animações fluidas + muitos wallpapers incluídos no repo
- **Ação recomendada no Claude Code:**
  ```bash
  git clone https://github.com/Sadrach34/Dotfiles.git /tmp/sadrach-dots
  ls /tmp/sadrach-dots/
  cat /tmp/sadrach-dots/README.md
  # Ver animações:
  cat /tmp/sadrach-dots/.config/hypr/conf/animations.conf
  # Contar wallpapers:
  find /tmp/sadrach-dots -name "*.jpg" -o -name "*.png" | wc -l
  ```
- Depois de analisar: extrair curvas bezier e timings de animação pro Lune OS

---

## Skills/plugins recomendados para o Claude Code

### /memory — Instruções persistentes
Cole isso no `/memory` do Claude Code ao iniciar:

```
Projeto: Lune OS — distro Linux Hyprland baseada em CachyOS
Repo: github.com/Razante21/lune-os (privado)
Stack: CachyOS, Hyprland 0.54, Waybar, Rofi, Kitty, Swaync, Swww, Wallust, SDDM
Syntaxe Hyprland 0.53+: windowrule = REGRA, match:class APP (nunca regex puro)
Layerrule: layerrule = blur on, match:namespace waybar (ignorezero = ignore_alpha)
Iniciar Hyprland: start-hyprland (nunca Hyprland direto)
Gemini model: gemini-3.1-flash-lite-preview (sempre este, nunca outro)
Shell do usuário na VM: fish (heredoc << EOF não funciona, usar python3 ou arquivos)
Pacote Inter no CachyOS: inter-font (não ttf-inter)
Paleta: lilás #C8A8E9, azul #7EB8F7, fundo #0D0E14
Sempre ler CONTEXT.md antes de qualquer tarefa
```

### Superpowers (plugin VSCode)
- Instalar: extensão "Claude Dev Superpowers" ou similar no marketplace
- Dá acesso a: memória expandida, busca web, ferramentas extras
- Útil para manter contexto entre sessões longas

### Fluxo de trabalho recomendado
1. Abrir Claude Code na pasta do repo lune-os
2. `/memory` com as instruções acima
3. Primera mensagem: "leia o CONTEXT.md"
4. Clonar repos de referência localmente para análise:
   ```bash
   git clone --depth=1 https://github.com/dhrruvsharma/shell.git /tmp/dhrruvshell
   git clone --depth=1 https://github.com/Sadrach34/Dotfiles.git /tmp/sadrach-dots
   git clone --depth=1 https://github.com/ilyamiro/nixos-configuration.git /tmp/ilyamiro
   git clone --depth=1 https://github.com/liixini/skwd.git /tmp/skwd
   git clone --depth=1 https://github.com/liixini/skwd-wall.git /tmp/skwd-wall
   git clone --depth=1 https://github.com/end-4/dots-hyprland.git /tmp/end4dots
   ```

---

## Pendências pós-quinta-feira

- [ ] Analisar Sadrach34/Dotfiles em detalhe (clonar local)
- [ ] Ver o dotfile impressionante do Reddit (link pendente — pós 06/05)
- [ ] Analisar skwd e skwd-wall do liixini em detalhe
- [ ] Analisar end-4/dots-hyprland em detalhe local
- [ ] Instalar CachyOS na partição do SSD principal (dual boot)
- [ ] Testar Hyprland no hardware real com AMD Vega 7
- [ ] Implementar Lune Media Hub (manga + anime + novel) — Bloco 3
- [ ] Implementar Wallpaper Picker em paralelepípedo — Bloco 3
- [ ] Migração progressiva Waybar → Quickshell — Bloco 4

---

*CONTEXT.md v1.0 — Lune OS — Abril 2026*
*"Your world, just lighter." 🌙*
*Última atualização: 13/04/2026*

---

## Sadrach34/Dotfiles — Análise parcial
- https://github.com/Sadrach34/Dotfiles
- Repo pessoal pequeno (3 stars, 50 commits)
- Descrito por Pedro como tendo animações muito boas e muitos wallpapers
- GitHub bloqueia acesso ao conteúdo interno via robots.txt
- **TODO para o Claude Code:** clonar localmente e analisar
  ```bash
  git clone https://github.com/Sadrach34/Dotfiles.git /tmp/sadrach-dots
  ls /tmp/sadrach-dots
  cat /tmp/sadrach-dots/README.md
  ls /tmp/sadrach-dots/.config/hypr/
  ```
- Referência principal: curvas bezier das animações e quantidade de wallpapers incluídos

---

## Outros repos descobertos durante pesquisa — Vale analisar

### liixini/skwd ⭐ O DOTFILE DO PARALELEPÍPEDO
- https://github.com/liixini/skwd
- Shell completo em Quickshell — daily driver do autor
- **App Launcher em paralelepípedo** (tiles inclinadas) com:
  - Splash art configurável por app
  - Search por tags customizadas
  - Ícones customizados
- **Window Switcher** em paralelepípedo com thumbnails ao vivo
- **Wallpaper Selector** visual em tiles skewed
- **Top Bar** com clock, weather, Wi-Fi, Bluetooth, volume, calendário
- **Music Player** com letras sincronizadas
- **Smarthome component** (IoT)
- **IA local** para análise e tagging de wallpapers (Ollama + Gemma3:4b)
- **Wallpaper Engine** animado via linux-wallpaperengine
- Suporte: CachyOS, Arch, Hyprland, Niri, KDE
- Em desenvolvimento ativo — commits diários

### noctalia-dev/noctalia-shell
- https://github.com/noctalia-dev/noctalia-shell
- Shell Quickshell com estética lavender (lilás — parecida com o Lune!)
- Suporta Hyprland, Niri, Sway, KDE e outros
- Theming extensivo com schemes predefinidas
- Integração com Wallhaven
- Disponível como pacote: `paru -S noctalia-shell`
- Boa referência por ter paleta similar ao Lune OS

### mylinuxforwork/dotfiles (ML4W OS)
- https://github.com/mylinuxforwork/dotfiles
- Dotfiles mais completos e bem documentados para Hyprland
- **Wallpaper effects** via ImageMagick (negate, brightness-contrast, etc.)
- **Settings App** dedicado com toggles visuais
- **Waypaper** como gerenciador de wallpapers
- **Glass theme** com Waybar centralizado
- Suporte Arch, Fedora, openSUSE
- Tem ISO própria para instalar direto
- Repo de wallpapers curados separado: github.com/mylinuxforwork/wallpaper

### BitterSweetcandyshop/wallpapers ⭐ REPOSITÓRIO DE WALLPAPERS
- https://github.com/BitterSweetcandyshop/wallpapers
- Coleção do canal #wallpapers do Discord r/unixporn + achados pessoais
- Organizado em pastas por tipo
- Fonte excelente para wallpapers de alta qualidade curados pela comunidade
- Pode clonar só as pastas que interessam

---

## Próximas ações pendentes (pós quinta-feira 13/04)

1. **Clonar e analisar localmente no Claude Code:**
   - `Sadrach34/Dotfiles` — animações e wallpapers
   - `liixini/skwd` — launcher paralelepípedo
   - `liixini/skwd-wall` — wallpaper picker
   - `dhrruvsharma/shell` — manga/anime/novel reader

2. **Testar no hardware real:**
   - Instalar CachyOS em partição do SSD principal
   - Rodar `bash scripts/install.sh` → opção Hyprland
   - Validar dotfiles com GPU real (AMD Vega 7)

3. **Revisar dotfile do Reddit (pós 06/05):**
   - O que Pedro achou abismador — link pendente

4. **Migração Waybar → Quickshell:**
   - Estudar arquitetura do dhrruvsharma/shell
   - Planejar migração gradual mantendo o visual Lune

5. **Implementar features novas (Bloco 3):**
   - Wallpaper picker em paralelepípedo (inspirado em skwd)
   - Leitor manga/manhwa/novel (inspirado em dhrruvsharma)
   - CAVA visualizer
   - Letras sincronizadas do Spotify

---

## Resumo rápido para o Claude Code começar

```
1. leia este CONTEXT.md completo
2. veja a estrutura do repo: ls -la e cat README.md
3. para qualquer dotfile de referência: git clone localmente primeiro
4. sintaxe Hyprland: SEMPRE usar match:class, nunca regex puro
5. modelo Gemini: SEMPRE gemini-3.1-flash-lite-preview
6. shell do usuário na VM: fish (não bash) — heredoc << 'EOF' não funciona
7. pacote Inter no CachyOS: inter-font (não ttf-inter)
```

*Documentação v0.9 — Abril 2026*
*"Your world, just lighter." 🌙*
*Pedro & Claude — Lune OS Project*
