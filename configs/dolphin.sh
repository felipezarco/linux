#!/usr/bin/env bash
#
# dolphin.sh — installs Dolphin (KDE file manager) and sets it as the default
# XDG handler for folders. Works on GNOME and XFCE; both honor the XDG
# mimeapps.list that xdg-mime writes to.
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when Dolphin is already present.

set -euo pipefail

DOLPHIN_DESKTOP="org.kde.dolphin.desktop"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Warning: not an apt-based system; install dolphin manually." >&2
  exit 0
fi

if dpkg -s dolphin >/dev/null 2>&1; then
  echo "Dolphin already installed."
else
  echo "Installing Dolphin (pulls in KDE Frameworks + Qt on GNOME/XFCE)..."
  sudo apt-get update -qq
  sudo apt-get install -y dolphin
fi

if [[ ! -f "/usr/share/applications/${DOLPHIN_DESKTOP}" ]]; then
  echo "Error: ${DOLPHIN_DESKTOP} not found; cannot set as default." >&2
  exit 1
fi

# Folders + a couple of adjacent MIMEs so that "open folder" from any app
# (nautilus links in email, drag-drop, GNOME/XFCE panels) routes to Dolphin.
for mime in inode/directory application/x-gnome-saved-search x-scheme-handler/file; do
  xdg-mime default "${DOLPHIN_DESKTOP}" "${mime}"
done

echo "Dolphin set as default file manager."
