#!/usr/bin/env bash
#
# gnome-tweaks.sh — installs GNOME Tweaks (advanced GNOME settings)
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when gnome-tweaks is already present.

set -euo pipefail

if dpkg -s gnome-tweaks >/dev/null 2>&1; then
  echo "gnome-tweaks already installed."
  exit 0
fi

echo "Installing gnome-tweaks..."
sudo apt install gnome-tweaks -y

echo "gnome-tweaks installed."
