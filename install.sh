#!/usr/bin/env bash
#
# install.sh — runs every configuration installer in configs/.
#
# Each file in configs/ is named after the software it configures
# (e.g. wezterm.sh) and is a self-contained, idempotent installer.
#
# Usage:
#   ./install.sh            # run all configs
#   ./install.sh wezterm    # run only configs/wezterm.sh
#   ./install.sh wezterm.sh # same thing (.sh is optional)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="${REPO_DIR}/configs"
LOG_FILE="${REPO_DIR}/install.log"

if [[ ! -d "${CONFIGS_DIR}" ]]; then
  echo "Error: configs directory not found at ${CONFIGS_DIR}" >&2
  exit 1
fi

# ── Script discovery ──────────────────────────────────────────────────────────
scripts=()
if [[ $# -gt 0 ]]; then
  for name in "$@"; do
    candidate="${CONFIGS_DIR}/${name%.sh}.sh"
    if [[ -f "${candidate}" ]]; then
      scripts+=("${candidate}")
    else
      printf 'Warning: no config named "%s" in configs/\n' "${name}" >&2
    fi
  done
else
  shopt -s nullglob
  scripts=("${CONFIGS_DIR}"/*.sh)
  shopt -u nullglob
fi

if [[ ${#scripts[@]} -eq 0 ]]; then
  echo "Nothing to install."
  exit 0
fi

# ── Human-readable descriptions ───────────────────────────────────────────────
describe_script() {
  case "$1" in
    zsh)           printf 'Updating terminal default to zsh instead of bash...' ;;
    fzf)           printf 'Installing fzf fuzzy finder...' ;;
    ranger)        printf 'Installing ranger for file navigation...' ;;
    wezterm)       printf 'Setting pre-defined configs for WezTerm...' ;;
    tmux)          printf 'Setting pre-defined configs for tmux...' ;;
    screenfetch)   printf 'Installing screenfetch for system info display...' ;;
    folder-color)  printf 'Installing Folder Color for custom folder icons...' ;;
    gnome-tweaks)  printf 'Installing GNOME Tweaks for advanced settings...' ;;
    *)             printf 'Installing %s...' "$1" ;;
  esac
}

# ── Progress bar ──────────────────────────────────────────────────────────────
_BAR_WIDTH=40
_drawn=0

draw_progress() {
  local current=$1 total=$2 label="$3"
  local pct=$(( current * 100 / total ))
  local filled=$(( current * _BAR_WIDTH / total ))
  local empty=$(( _BAR_WIDTH - filled ))

  local bar_filled="" bar_empty=""
  [[ $filled -gt 0 ]] && bar_filled="$(printf "%${filled}s" | tr ' ' '#')"
  [[ $empty  -gt 0 ]] && bar_empty="$(printf "%${empty}s"  | tr ' ' '-')"

  if [[ $_drawn -gt 0 ]]; then
    printf '\033[%dA' "$_drawn"
  fi
  printf '\033[2K[%s%s] %3d%% (%d/%d)\n' "$bar_filled" "$bar_empty" "$pct" "$current" "$total"
  printf '\033[2K  %s\n' "$label"
  _drawn=2
}

# ── Run ───────────────────────────────────────────────────────────────────────
total=${#scripts[@]}
: > "${LOG_FILE}"

printf 'Installing %d package(s)  ·  full output → %s\n\n' "$total" "${LOG_FILE}"

failed=()
for i in "${!scripts[@]}"; do
  script="${scripts[$i]}"
  name="$(basename "${script}" .sh)"
  label="$(describe_script "${name}")"

  draw_progress "$i" "$total" "$label"

  bash "${script}" >> "${LOG_FILE}" 2>&1 || failed+=("${name}")
done

draw_progress "$total" "$total" "All done."
echo

if [[ ${#failed[@]} -gt 0 ]]; then
  for name in "${failed[@]}"; do
    printf '  \033[31m✗  %s failed\033[0m\n' "$name" >&2
  done
  printf '\n  See %s for details.\n\n' "${LOG_FILE}" >&2
  exit 1
fi

printf '  \033[32m✓  All %d configs installed successfully.\033[0m\n\n' "$total"
