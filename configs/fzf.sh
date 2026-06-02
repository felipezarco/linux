#!/usr/bin/env bash
#
# fzf.sh — installs the fzf binary (fuzzy finder) into ~/.fzf
#
# Self-contained and idempotent: skips if ~/.fzf already exists.
# Generates key-bindings + completion into ~/.fzf.zsh, but does NOT edit
# ~/.zshrc — the rc wiring (source ~/.fzf.zsh) lives in zsh.sh.

set -euo pipefail

FZF_DIR="${HOME}/.fzf"

if [[ -d "${FZF_DIR}" ]]; then
  echo "fzf already installed: $("${FZF_DIR}/bin/fzf" --version 2>/dev/null || echo '?')"
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required to install fzf." >&2
  exit 1
fi

echo "Cloning fzf -> ${FZF_DIR}"
git clone --depth 1 https://github.com/junegunn/fzf.git "${FZF_DIR}"

# --all: key-bindings + completion, fully non-interactive.
# --no-update-rc: leave ~/.zshrc untouched (zsh.sh owns the rc wiring).
"${FZF_DIR}/install" --all --no-update-rc

echo "fzf installed: $("${FZF_DIR}/bin/fzf" --version)"
