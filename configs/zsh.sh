#!/usr/bin/env bash
#
# zsh.sh — installs zsh + oh-my-zsh + plugins and wires up ~/.zshrc
#
# Tools set up here:
#   - zsh                      (apt)
#   - oh-my-zsh                (official installer, unattended, keeps ~/.zshrc)
#   - zsh-syntax-highlighting  (cloned to ~/zsh-syntax-highlighting, sourced)
#   - zsh-autosuggestions      (oh-my-zsh custom plugin)
#   - plugin list + fzf wiring + aliases in ~/.zshrc
#
# The fzf BINARY is installed by fzf.sh; here we only reference ~/.fzf.zsh.
#
# Self-contained and idempotent: every step is skipped when already done, and
# ~/.zshrc is backed up before any edit. Targets Debian/Ubuntu (apt).

set -euo pipefail

ZSHRC="${HOME}/.zshrc"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
SYNTAX_DIR="${HOME}/zsh-syntax-highlighting"
AUTOSUGG_DIR="${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"

# Append a whole line to a file only if that exact line isn't already present.
append_once() {
  local line="$1" file="$2"
  grep -qxF -- "${line}" "${file}" 2>/dev/null || printf '%s\n' "${line}" >> "${file}"
}

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Warning: not an apt-based system; install zsh/oh-my-zsh manually." >&2
  exit 0
fi

# --- 1. Base packages -------------------------------------------------------
# (Original recipe used 'snap install curl'; apt is more reliable/consistent.)
echo "Installing base packages (zsh, git, curl)..."
sudo apt-get update -qq
sudo apt-get install -y zsh git curl

# --- 2. oh-my-zsh -----------------------------------------------------------
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  echo "oh-my-zsh already installed."
else
  echo "Installing oh-my-zsh (unattended, keeping any existing ~/.zshrc)..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    echo "Error: oh-my-zsh installation failed." >&2
    exit 1
  fi
fi

# --- 3. Plugins -------------------------------------------------------------
if [[ -d "${SYNTAX_DIR}" ]]; then
  echo "zsh-syntax-highlighting already present."
else
  echo "Cloning zsh-syntax-highlighting -> ${SYNTAX_DIR}"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${SYNTAX_DIR}"
fi

if [[ -d "${AUTOSUGG_DIR}" ]]; then
  echo "zsh-autosuggestions already present."
else
  echo "Cloning zsh-autosuggestions -> ${AUTOSUGG_DIR}"
  git clone https://github.com/zsh-users/zsh-autosuggestions "${AUTOSUGG_DIR}"
fi

# --- 4. ~/.zshrc wiring (backup first) --------------------------------------
if [[ -f "${ZSHRC}" ]]; then
  cp "${ZSHRC}" "${ZSHRC}.bak.$(date +%Y%m%d-%H%M%S)"
fi

# Set the oh-my-zsh plugin list, replacing whatever plugins=(...) is there
# (works for both the single-line default and a multi-line array).
if command -v perl >/dev/null 2>&1; then
  perl -0777 -pi -e \
    's/^plugins=\([^)]*\)/plugins=(\n  git\n  zsh-autosuggestions\n  fzf\n)/m' "${ZSHRC}"
else
  echo "Warning: perl not found; make sure plugins=(git zsh-autosuggestions fzf) by hand." >&2
fi

# Source zsh-syntax-highlighting (skip if already sourced in any form).
grep -q "zsh-syntax-highlighting.zsh" "${ZSHRC}" \
  || append_once "source \"${SYNTAX_DIR}/zsh-syntax-highlighting.zsh\"" "${ZSHRC}"

# Source fzf shell integration if present (binary comes from fzf.sh).
grep -q "\.fzf\.zsh" "${ZSHRC}" \
  || append_once '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' "${ZSHRC}"

# Personal aliases (targets code-insiders / terminator are installed separately).
append_once "alias code='code-insiders'" "${ZSHRC}"
append_once "alias term='terminator'" "${ZSHRC}"

# tmux auto-session: first terminal attaches "main"; each split gets its own
# numbered session (1, 2, 3, …) so panes are independent instead of mirrored.
# (tmux itself isn't installed here; the block is guarded by `command -v tmux`.)
# Drop any legacy single-line auto-attach first so it can't `exec` before this.
if command -v perl >/dev/null 2>&1; then
  perl -ni -e 'print unless /exec tmux new-session -A -s main/' "${ZSHRC}"
fi
if ! grep -q 'tmux: first terminal gets/reattaches' "${ZSHRC}"; then
  cat >> "${ZSHRC}" <<'TMUXBLOCK'

# tmux: first terminal gets/reattaches "main"; each new split gets its own
# numbered session (1, 2, 3, …) so panes are independent instead of mirrored.
if [ -z "$TMUX" ] && command -v tmux >/dev/null; then
  if ! tmux has-session -t main 2>/dev/null; then
    exec tmux new-session -s main          # no main yet → create it
  elif [ -z "$(tmux list-clients -t main 2>/dev/null)" ]; then
    exec tmux attach-session -t main       # main idle (reopened) → reattach
  else
    i=1; while tmux has-session -t "$i" 2>/dev/null; do i=$((i + 1)); done
    exec tmux new-session -s "$i"          # main busy → fresh numbered session
  fi
fi
TMUXBLOCK
fi

echo "~/.zshrc configured."

# --- 5. Default shell -------------------------------------------------------
current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
zsh_path="$(command -v zsh)"
if [[ "${current_shell}" != "${zsh_path}" ]]; then
  echo "Setting default shell to zsh (chsh may ask for your password)..."
  chsh -s "${zsh_path}" || echo "Warning: chsh failed; run 'chsh -s ${zsh_path}' manually." >&2
else
  echo "Default shell already zsh."
fi

echo "zsh setup done. Open a new terminal (or run: exec zsh) to load it."
