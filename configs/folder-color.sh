#!/usr/bin/env bash
#
# folder-color.sh — installs Folder Color (custom folder colors in Nautilus)
#
# GNOME-only: the folder-color extension hooks into Nautilus/Nemo/Caja. XFCE
# uses Thunar, which is not supported, so the script skips itself there.
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when folder-color is already present.

set -euo pipefail

# ── Desktop gate ────────────────────────────────────────────────────────────
# install.sh exports $DESKTOP; when run standalone, detect it here.
if [[ -z "${DESKTOP:-}" ]]; then
  for token in ${XDG_CURRENT_DESKTOP//:/ } ${DESKTOP_SESSION:-}; do
    case "${token^^}" in
      GNOME|UBUNTU) DESKTOP=GNOME; break ;;
      XFCE)         DESKTOP=XFCE;  break ;;
    esac
  done
  DESKTOP="${DESKTOP:-UNKNOWN}"
fi

if [[ "${DESKTOP}" != "GNOME" ]]; then
  echo "Skipping folder-color: needs Nautilus/Nemo/Caja (detected ${DESKTOP})."
  exit 0
fi

if dpkg -s folder-color >/dev/null 2>&1; then
  echo "folder-color already installed."
  exit 0
fi

echo "Adding folder-color PPA..."
sudo add-apt-repository ppa:costales/folder-color -y

echo "Updating package lists..."
sudo apt update

echo "Installing folder-color..."
sudo apt install folder-color -y

echo "folder-color installed."
