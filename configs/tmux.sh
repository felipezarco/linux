#!/usr/bin/env bash
#
# tmux.sh — installs tmux + xclip (if missing) and writes the config to ~/.tmux.conf
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when the packages are already present, and
# backs up any existing config (with a timestamp) before overwriting it.
#
# xclip is required by the config: with `mouse on`, tmux owns the mouse, so a
# drag selection would only land in tmux's internal buffer (the highlight
# vanishes on release and Ctrl+Shift+V pastes nothing). The bindings below
# pipe every copy through xclip into the system clipboard instead.

set -euo pipefail

CONFIG_PATH="${HOME}/.tmux.conf"

# ---------------------------------------------------------------------------
# 1. Make sure tmux and xclip are installed.
# ---------------------------------------------------------------------------
install_packages() {
  local missing=()
  command -v tmux  >/dev/null 2>&1 || missing+=(tmux)
  command -v xclip >/dev/null 2>&1 || missing+=(xclip)

  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "tmux already installed: $(tmux -V); xclip present"
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Warning: ${missing[*]} not found and this is not an apt-based system." >&2
    echo "         Install manually with your package manager." >&2
    return 0
  fi

  echo "Installing ${missing[*]}..."
  sudo apt-get update -qq
  sudo apt-get install -y "${missing[@]}"
  echo "Installed ${missing[*]} ($(tmux -V))"
}

install_packages

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

# Copy to the SYSTEM clipboard (X11, via xclip). Without this the mouse
# selection only lands in tmux's internal buffer and the highlight vanishes
# on release, so Ctrl+Shift+V in the terminal pastes nothing.
# Tip: hold Shift while dragging to bypass tmux and use the terminal's own
# selection instead.
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
bind -T copy-mode-vi DoubleClick1Pane  select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
bind -T copy-mode-vi TripleClick1Pane  select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
bind -T copy-mode-vi y                 send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
bind -T copy-mode-vi Enter             send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
CONF

echo "tmux config written -> ${CONFIG_PATH}"

# Reload into any running tmux server so the change takes effect now.
if command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; then
  tmux source-file "${CONFIG_PATH}" && echo "Reloaded config into running tmux."
fi
