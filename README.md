# linux

Repositório central das minhas configurações dinâmicas (dotfiles) no Linux.

Cada arquivo em `configs/` é um instalador **independente e idempotente**, nomeado
pelo software que configura (ex.: `wezterm.sh`). O `install.sh` roda todos eles.

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
    ├── fzf.sh             # instala o binário do fzf em ~/.fzf
    ├── ranger.sh          # instala ranger + escreve ~/.config/ranger/rc.conf
    ├── screenfetch.sh     # instala screenFetch
    ├── wezterm.sh         # instala WezTerm + escreve ~/.wezterm.lua
    └── zsh.sh             # zsh + oh-my-zsh + plugins + ~/.zshrc
```

> O `install.sh` roda os scripts em ordem alfabética (`fzf`, `ranger`,
> `screenfetch`, `wezterm`, `zsh`). O `zsh.sh` é dono de todo o `~/.zshrc`; o `fzf.sh` só
> instala o binário (não mexe no `~/.zshrc`), então a ordem entre eles não importa.

## Configurações disponíveis

| Software | Script               | O que faz                                                                                                  |
|----------|----------------------|------------------------------------------------------------------------------------------------------------|
| WezTerm     | `configs/wezterm.sh`     | Instala o WezTerm (repo oficial `apt.fury.io/wez`, se faltar) e escreve `~/.wezterm.lua`: keybindings de panes; `Ctrl+W` e `Ctrl+Shift+W` fecham só o pane atual. |
| screenFetch | `configs/screenfetch.sh` | Instala o screenFetch (info do sistema no terminal). Sem arquivo de config.                                |
| zsh         | `configs/zsh.sh`         | Instala zsh + oh-my-zsh + `zsh-syntax-highlighting` + `zsh-autosuggestions`; ajusta `plugins=(...)`, sourcing e aliases (`code`, `term`) no `~/.zshrc`; define o zsh como shell padrão. |
| fzf         | `configs/fzf.sh`         | Instala o binário do fzf em `~/.fzf` (`--all --no-update-rc`); a integração com o shell é referenciada pelo `zsh.sh`. |
| ranger      | `configs/ranger.sh`      | Instala o ranger (gerenciador de arquivos no terminal, via apt) e escreve `~/.config/ranger/rc.conf` com overrides: mostra dotfiles, bordas, previews (`scope.sh`) e título da janela. |

## Adicionando uma nova configuração

1. Crie `configs/<software>.sh` (ex.: `nvim.sh`, `zsh.sh`).
2. Comece com `#!/usr/bin/env bash` e `set -euo pipefail`.
3. Faça backup do arquivo de destino antes de sobrescrever.
4. Pronto — o `install.sh` passa a incluí-lo automaticamente.
