#!/usr/bin/env bash
#
# ranger.sh — installs ranger (terminal file manager) and writes a small
#             config override to ~/.config/ranger/rc.conf
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when ranger is already present, and backs up
# any existing config (with a timestamp) before overwriting it.
#
# ranger loads its built-in default rc.conf first and then layers the user's
# ~/.config/ranger/rc.conf on top, so this file only needs to list the few
# settings we want to override — all default keybindings stay intact.

set -euo pipefail

CONFIG_DIR="${HOME}/.config/ranger"
CONFIG_PATH="${CONFIG_DIR}/rc.conf"

# ---------------------------------------------------------------------------
# 1. Make sure ranger itself is installed.
# ---------------------------------------------------------------------------
install_ranger() {
  if command -v ranger >/dev/null 2>&1; then
    echo "ranger already installed: $(ranger --version 2>&1 | head -1)"
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Warning: ranger not found and this is not an apt-based system." >&2
    echo "         Install it with your package manager (e.g. brew install ranger)." >&2
    return 0
  fi

  echo "Installing ranger..."
  sudo apt-get update -qq
  sudo apt-get install -y ranger
  echo "ranger installed: $(ranger --version 2>&1 | head -1)"
}

install_ranger

# ---------------------------------------------------------------------------
# 2. Write the config (backing up any existing one first).
# ---------------------------------------------------------------------------
mkdir -p "${CONFIG_DIR}"

if [[ -f "${CONFIG_PATH}" ]]; then
  backup="${CONFIG_PATH}.bak.$(date +%Y%m%d-%H%M%S)"
  cp "${CONFIG_PATH}" "${backup}"
  echo "Backed up existing config -> ${backup}"
fi

cat > "${CONFIG_PATH}" <<'CONF'
# ~/.config/ranger/rc.conf
#
# Only overrides — ranger loads its built-in defaults first, so every default
# keybinding and setting not listed here still applies.

# Show dotfiles by default (toggle at runtime with zh).
set show_hidden true

# Draw borders around the columns for a clearer layout.
set draw_borders both

# Preview files in the right-hand column, including directory contents.
set preview_files true
set preview_directories true

# Use scope.sh for richer previews (syntax highlighting, archives, etc.).
set use_preview_script true

# Ask for confirmation only when deleting multiple files at once.
set confirm_on_delete multiple

# Update the terminal window title to the current directory.
set update_title true
CONF

echo "ranger config written -> ${CONFIG_PATH}"
