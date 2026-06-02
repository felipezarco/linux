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

# Resolve the repo root (directory of this script) so it works from anywhere.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="${REPO_DIR}/configs"

if [[ ! -d "${CONFIGS_DIR}" ]]; then
  echo "Error: configs directory not found at ${CONFIGS_DIR}" >&2
  exit 1
fi

# Build the list of scripts to run: the names passed as args, or all of them.
scripts=()
if [[ $# -gt 0 ]]; then
  for name in "$@"; do
    candidate="${CONFIGS_DIR}/${name%.sh}.sh"
    if [[ -f "${candidate}" ]]; then
      scripts+=("${candidate}")
    else
      echo "Warning: no config named '${name}' in configs/" >&2
    fi
  done
else
  shopt -s nullglob               # empty list (not literal '*.sh') if none match
  scripts=("${CONFIGS_DIR}"/*.sh)
  shopt -u nullglob
fi

if [[ ${#scripts[@]} -eq 0 ]]; then
  echo "Nothing to install."
  exit 0
fi

failed=()
for script in "${scripts[@]}"; do
  name="$(basename "${script}" .sh)"
  echo "==> ${name}"
  # Run in a subshell (bash <file>) so one installer's set -e / exit
  # cannot abort the others; the 'if' keeps our own set -e from tripping.
  if bash "${script}"; then
    echo "    ok"
  else
    echo "    FAILED" >&2
    failed+=("${name}")
  fi
  echo
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "Done with errors. Failed: ${failed[*]}" >&2
  exit 1
fi

echo "All configs installed."
