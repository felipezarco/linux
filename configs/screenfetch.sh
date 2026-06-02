#!/usr/bin/env bash
#
# screenfetch.sh — installs screenFetch (system info / ASCII logo on terminal)
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: skips the install when screenfetch is already present.
# screenFetch has no config file, so this script only handles installation.
#
# Available from the Ubuntu/Debian repos, so a plain apt install is enough.

set -euo pipefail

if command -v screenfetch >/dev/null 2>&1; then
  echo "screenFetch already installed: $(screenfetch --version 2>&1 | head -1)"
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Warning: screenfetch not found and this is not an apt-based system." >&2
  echo "         Install it with your package manager (e.g. brew install screenfetch)." >&2
  exit 0
fi

echo "Installing screenFetch..."
sudo apt-get update -qq
sudo apt-get install -y screenfetch

echo "screenFetch installed: $(screenfetch --version 2>&1 | head -1)"
