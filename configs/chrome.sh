#!/usr/bin/env bash
#
# chrome.sh — installs Google Chrome (stable) if missing and sets it as the
# default web browser + default handler for http/https/html.
#
# Install method: downloads Google's official .deb and installs it with apt.
# The package post-install adds /etc/apt/sources.list.d/google-chrome.sources
# and the signing key, so future updates flow through normal apt upgrade.
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when Chrome is already present.

set -euo pipefail

CHROME_DESKTOP="google-chrome.desktop"
CHROME_DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Warning: not an apt-based system; install Chrome manually." >&2
  exit 0
fi

if command -v google-chrome >/dev/null 2>&1 \
   || command -v google-chrome-stable >/dev/null 2>&1; then
  echo "Chrome already installed."
else
  echo "Installing Google Chrome from ${CHROME_DEB_URL}..."
  # curl is a hard dep here; other scripts (wezterm, zsh) also install it, but
  # chrome.sh must stand on its own if run directly.
  if ! command -v curl >/dev/null 2>&1; then
    sudo apt-get install -y curl
  fi
  TMP_DEB="$(mktemp --suffix=.deb)"
  trap 'rm -f "${TMP_DEB}"' EXIT
  curl -fsSL "${CHROME_DEB_URL}" -o "${TMP_DEB}"
  # apt-get install handles dependency resolution for local .debs (unlike dpkg).
  sudo apt-get install -y "${TMP_DEB}"
fi

if [[ ! -f "/usr/share/applications/${CHROME_DESKTOP}" ]]; then
  echo "Error: ${CHROME_DESKTOP} not found; cannot set as default." >&2
  exit 1
fi

# xdg-settings is the canonical way to switch the browser; xdg-mime covers the
# handlers that xdg-settings doesn't touch on every distro.
if command -v xdg-settings >/dev/null 2>&1; then
  xdg-settings set default-web-browser "${CHROME_DESKTOP}"
fi
for mime in \
    x-scheme-handler/http \
    x-scheme-handler/https \
    x-scheme-handler/about \
    x-scheme-handler/unknown \
    text/html; do
  xdg-mime default "${CHROME_DESKTOP}" "${mime}"
done

echo "Chrome set as default browser."
