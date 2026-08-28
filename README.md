# linux

Repositório central das minhas configurações dinâmicas (dotfiles) no Linux.

Cada arquivo em `configs/` é um instalador **independente e idempotente**, nomeado
pelo software que configura (ex.: `wezterm.sh`). O `install.sh` roda todos eles.

> **Suporte de desktop:** este repo só funciona em **GNOME** e **XFCE** (testado em
> Ubuntu / derivados baseados em `apt`). O `install.sh` detecta o desktop via
> `XDG_CURRENT_DESKTOP` e recusa rodar em outros (KDE, Cinnamon, etc.).
> Scripts específicos de GNOME (`gnome-tweaks.sh`, `folder-color.sh`) se pulam
> sozinhos no XFCE com uma mensagem clara. O `evolution.sh` aplica a
> configuração de som via `gsettings` no GNOME e via `xfconf-query` no XFCE.

## Instalação

```bash
git clone <url-do-repo> ~/linux && cd ~/linux && ./install.sh
```

Se o repositório já estiver clonado:

```bash
cd ~/linux && ./install.sh
```

## Uso

```bash
./install.sh            # aplica todas as configurações
./install.sh wezterm    # aplica apenas configs/wezterm.sh
```

Cada instalador faz backup do arquivo existente (com timestamp) antes de sobrescrever.

## Estrutura

```
linux/
├── README.md
├── install.sh             # orquestra todos os instaladores em configs/
└── configs/
    ├── evolution.sh      # instala Evolution + som, assinatura, prefs e autostart
    ├── evolution/        # assets e templates usados pelo evolution.sh
    │   ├── assets/       #   imagem da assinatura + som (yougotmail.ogg)
    │   ├── signature.source
    │   ├── signature.html.tmpl
    │   └── evolution.dconf
    ├── chrome.sh          # instala Google Chrome + seta como browser padrão
    ├── dolphin.sh         # instala Dolphin + seta como file manager padrão
    ├── folder-color.sh    # (só GNOME) cores customizadas em pastas
    ├── fzf.sh             # instala o binário do fzf em ~/.fzf
    ├── gnome-tweaks.sh    # (só GNOME) GNOME Tweaks
    ├── ranger.sh          # instala ranger + escreve ~/.config/ranger/rc.conf
    ├── screenfetch.sh     # instala screenFetch
    ├── tmux.sh            # instala tmux + escreve ~/.tmux.conf
    ├── wezterm.sh         # instala WezTerm + escreve ~/.wezterm.lua
    └── zsh.sh             # zsh + oh-my-zsh + plugins + ~/.zshrc
```

> O `install.sh` roda os scripts em ordem alfabética (`fzf`, `ranger`,
> `screenfetch`, `wezterm`, `zsh`). O `zsh.sh` é dono de todo o `~/.zshrc`; o `fzf.sh` só
> instala o binário (não mexe no `~/.zshrc`), então a ordem entre eles não importa.

## Configurações disponíveis

| Software | Script               | O que faz                                                                                                  |
|----------|----------------------|------------------------------------------------------------------------------------------------------------|
| WezTerm     | `configs/wezterm.sh`     | Instala o WezTerm (repo oficial `apt.fury.io/wez`, se faltar) e escreve `~/.wezterm.lua`: keybindings de panes; `Ctrl+W` e `Ctrl+Shift+W` fecham só o pane atual. Também instala um `.desktop` de usuário sobrescrevendo o ícone pelo genérico `utilities-terminal` do tema. |
| screenFetch | `configs/screenfetch.sh` | Instala o screenFetch (info do sistema no terminal). Sem arquivo de config.                                |
| zsh         | `configs/zsh.sh`         | Instala zsh + oh-my-zsh + `zsh-syntax-highlighting` + `zsh-autosuggestions`; ajusta `plugins=(...)`, sourcing e aliases (`code`, `term`) no `~/.zshrc`; define o zsh como shell padrão. |
| fzf         | `configs/fzf.sh`         | Instala o binário do fzf em `~/.fzf` (`--all --no-update-rc`); a integração com o shell é referenciada pelo `zsh.sh`. |
| ranger      | `configs/ranger.sh`      | Instala o ranger (gerenciador de arquivos no terminal, via apt) e escreve `~/.config/ranger/rc.conf` com overrides: mostra dotfiles, bordas, previews (`scope.sh`) e título da janela. |
| Evolution   | `configs/evolution.sh`   | Instala o Evolution (via apt) e restaura a configuração **independente de conta**: copia os assets para `~/common`; define o **som de novo e-mail** global (`yougotmail.ogg`); instala a **assinatura** "Assinatura Zarco" (disponível, mas não aplicada por padrão) com o caminho da imagem corrigido; aplica **preferências e layout dos painéis** via dconf; cria o **autostart** (`~/.config/autostart/`) para o Evolution abrir no login; define o Evolution como **handler padrão** de `mailto:` e `.eml` via `xdg-mime`. Não cria contas nem guarda senhas. A assinatura só é vinculada à identidade `felipe.zarco@agxsoftware.com` se essa conta já existir — rode de novo depois de adicionar a conta para vinculá-la. |
| tmux            | `configs/tmux.sh`         | Instala o tmux (via apt) e escreve `~/.tmux.conf`. |
| gnome-tweaks    | `configs/gnome-tweaks.sh` | Instala o GNOME Tweaks (via apt). **Só GNOME.** |
| folder-color    | `configs/folder-color.sh` | Instala o folder-color (PPA `costales/folder-color`) para cores customizadas em pastas do Nautilus/Nemo/Caja. **Só GNOME.** |
| Dolphin         | `configs/dolphin.sh`      | Instala o Dolphin (via apt) e o define como **file manager padrão** para `inode/directory` via `xdg-mime`. Funciona em GNOME e XFCE. |
| Google Chrome   | `configs/chrome.sh`       | Instala o Google Chrome estável (baixa o `.deb` oficial, que também configura o repo apt para atualizações) e o define como **browser padrão** via `xdg-settings` + `xdg-mime` para `http/https/html`. |

## Adicionando uma nova configuração

1. Crie `configs/<software>.sh` (ex.: `nvim.sh`, `zsh.sh`).
2. Comece com `#!/usr/bin/env bash` e `set -euo pipefail`.
3. Faça backup do arquivo de destino antes de sobrescrever.
4. Pronto — o `install.sh` passa a incluí-lo automaticamente.
