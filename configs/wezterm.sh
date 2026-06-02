#!/usr/bin/env bash
#
# wezterm.sh — installs WezTerm (if missing) and writes its config to ~/.wezterm.lua
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when WezTerm is already present, and backs up
# any existing config (with a timestamp) before overwriting it.
#
# Install method mirrors the official WezTerm APT repo (apt.fury.io/wez), so it
# targets Debian/Ubuntu. On non-apt systems it skips install and just writes
# the config.

set -euo pipefail

CONFIG_PATH="${HOME}/.wezterm.lua"
KEYRING="/usr/share/keyrings/wezterm-fury.gpg"
SOURCE_LIST="/etc/apt/sources.list.d/wezterm.list"
GPG_KEY_URL="https://apt.fury.io/wez/gpg.key"
APT_REPO="deb [signed-by=${KEYRING}] https://apt.fury.io/wez/ * *"

# ---------------------------------------------------------------------------
# 1. Make sure WezTerm itself is installed.
# ---------------------------------------------------------------------------
install_wezterm() {
  if command -v wezterm >/dev/null 2>&1; then
    echo "WezTerm already installed: $(wezterm --version)"
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Warning: WezTerm not found and this is not an apt-based system." >&2
    echo "         Install it manually: https://wezterm.org/install/linux.html" >&2
    return 0
  fi

  echo "Installing WezTerm from the official APT repo (apt.fury.io/wez)..."
  sudo apt-get update -qq
  sudo apt-get install -y curl gpg

  # Add the signing key (dearmored) and the repo, then install.
  curl -fsSL "${GPG_KEY_URL}" | sudo gpg --yes --dearmor -o "${KEYRING}"
  echo "${APT_REPO}" | sudo tee "${SOURCE_LIST}" >/dev/null
  sudo apt-get update
  sudo apt-get install -y wezterm

  echo "WezTerm installed: $(wezterm --version)"
}

install_wezterm

# ---------------------------------------------------------------------------
# 2. Write the config (backing up any existing one first).
# ---------------------------------------------------------------------------
if [[ -f "${CONFIG_PATH}" ]]; then
  backup="${CONFIG_PATH}.bak.$(date +%Y%m%d-%H%M%S)"
  cp "${CONFIG_PATH}" "${backup}"
  echo "Backed up existing config -> ${backup}"
fi

cat > "${CONFIG_PATH}" <<'LUA'
local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- Keybindings para gerenciar splits (panes).
-- Esses bindings se somam aos defaults do WezTerm; em caso de conflito, vencem.
config.keys = {
  -- Fechar SOMENTE o pane atual (não a tab nem a janela).
  -- confirm = false fecha na hora; troque para true se quiser confirmação.
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = false } },

  -- Novo split à direita (panes lado a lado)
  { key = 'O', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- Novo split abaixo (panes empilhados)
  { key = 'E', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Zoom/foco no split atual (toggle)
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },

  -- Navegar entre panes (mover o foco na direção da seta)
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },

  -- Redimensionar o split.
  -- Obs: o WezTerm mede em CÉLULAS, não em pixels. Usei 5 células por toque;
  -- ajuste o número abaixo se quiser passos maiores/menores.
  { key = 'LeftArrow',  mods = 'SUPER|CTRL|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'SUPER|CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow',    mods = 'SUPER|CTRL|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'DownArrow',  mods = 'SUPER|CTRL|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
}

return config
LUA

echo "WezTerm config written -> ${CONFIG_PATH}"

# Validate the config if the wezterm binary is available.
if command -v wezterm >/dev/null 2>&1; then
  if wezterm --config-file "${CONFIG_PATH}" show-keys >/dev/null 2>&1; then
    echo "Config validated OK."
  else
    echo "Warning: wezterm could not validate the config. Check ${CONFIG_PATH}." >&2
  fi
fi
