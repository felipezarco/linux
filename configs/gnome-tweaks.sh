#!/usr/bin/env bash
#
# gnome-tweaks.sh — installs GNOME Tweaks (advanced GNOME settings)
#
# GNOME-only: gnome-tweaks manipulates gsettings under org.gnome.* and has no
# meaning outside GNOME Shell, so this script skips itself on other desktops.
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when gnome-tweaks is already present.

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
  echo "Skipping gnome-tweaks: GNOME-only tool (detected ${DESKTOP})."
  exit 0
fi

if dpkg -s gnome-tweaks >/dev/null 2>&1; then
  echo "gnome-tweaks already installed."
  exit 0
fi

echo "Installing gnome-tweaks..."
sudo apt install gnome-tweaks -y

echo "gnome-tweaks installed."
