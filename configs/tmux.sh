#!/usr/bin/env bash
#
# tmux.sh — installs tmux (if missing) and writes its config to ~/.tmux.conf
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when tmux is already present, and backs up
# any existing config (with a timestamp) before overwriting it.

set -euo pipefail

CONFIG_PATH="${HOME}/.tmux.conf"

# ---------------------------------------------------------------------------
# 1. Make sure tmux itself is installed.
# ---------------------------------------------------------------------------
install_tmux() {
  if command -v tmux >/dev/null 2>&1; then
    echo "tmux already installed: $(tmux -V)"
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Warning: tmux not found and this is not an apt-based system." >&2
    echo "         Install it manually with your package manager." >&2
    return 0
  fi

  echo "Installing tmux..."
  sudo apt-get update -qq
  sudo apt-get install -y tmux
  echo "tmux installed: $(tmux -V)"
}

install_tmux

# ---------------------------------------------------------------------------
# 2. Write the config (backing up any existing one first).
# ---------------------------------------------------------------------------
if [[ -f "${CONFIG_PATH}" ]]; then
  backup="${CONFIG_PATH}.bak.$(date +%Y%m%d-%H%M%S)"
  cp "${CONFIG_PATH}" "${backup}"
  echo "Backed up existing config -> ${backup}"
fi

cat > "${CONFIG_PATH}" <<'CONF'
# ~/.tmux.conf

# Enable the mouse: the scroll wheel now scrolls back through history
# vertically (entering copy mode automatically), click selects panes/
# windows, and dragging a border resizes splits.
set -g mouse on

# Deep scrollback buffer. Default is only 2000 lines, which truncates the
# start of long output. Applies to panes created AFTER this is loaded.
set -g history-limit 100000

# vi-style keys in copy mode (k/j, PageUp/PageDown, / to search, q to quit).
setw -g mode-keys vi

# Smooth wheel scrolling: 3 lines per notch instead of a full page. Selecting
# the pane under the cursor first means the wheel scrolls whatever you're over.
bind -T copy-mode-vi WheelUpPane   select-pane \; send-keys -X -N 3 scroll-up
bind -T copy-mode-vi WheelDownPane select-pane \; send-keys -X -N 3 scroll-down
CONF

echo "tmux config written -> ${CONFIG_PATH}"

# Reload into any running tmux server so the change takes effect now.
if command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; then
  tmux source-file "${CONFIG_PATH}" && echo "Reloaded config into running tmux."
fi
