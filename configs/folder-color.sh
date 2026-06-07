#!/usr/bin/env bash
#
# folder-color.sh — installs Folder Color (custom folder colors in Nautilus)
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when folder-color is already present.

set -euo pipefail

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
