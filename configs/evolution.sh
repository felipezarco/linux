#!/usr/bin/env bash
#
# evolution.sh — installs the Evolution mail client and restores a portable,
#                account-independent configuration:
#
#   • new-mail notification SOUND  — global, plays for every account
#   • an HTML SIGNATURE ("Assinatura Zarco") — made *available* in Evolution and
#     auto-linked to the felipe.zarco@agxsoftware.com identity ONLY if that
#     account already exists on the machine. It is never applied to personal
#     accounts, so composing from a home account sends no company signature.
#   • general PREFERENCES / panel layout — via a curated dconf key-file.
#
# What it deliberately does NOT do: it never creates mail accounts, servers or
# stores passwords. Accounts stay a manual step; this script only restores the
# configuration that surrounds them.
#
# Self-contained: can be run directly or via ../install.sh.
# Idempotent: safe to re-run. In particular, re-run it *after* you have added
# the company account and it will link the signature to that identity.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_SRC="${SCRIPT_DIR}/evolution/assets"
SIG_SOURCE_TMPL="${SCRIPT_DIR}/evolution/signature.source"
SIG_HTML_TMPL="${SCRIPT_DIR}/evolution/signature.html.tmpl"
DCONF_FILE="${SCRIPT_DIR}/evolution/evolution.dconf"

# Where the shared assets (signature image + sound) live on the machine. The
# signature HTML references the image by absolute path, so this must be stable.
ASSET_DIR="${HOME}/common"

# Stable UID for the signature: matches the existing one so re-runs update the
# same signature instead of creating duplicates. The signature's source file and
# its HTML body file must both be named after this UID.
SIG_UID="d96404ee59e9246b8ad93849262e5173410d7608"
COMPANY_ADDRESS="felipe.zarco@agxsoftware.com"

EVO_CONFIG="${HOME}/.config/evolution"
SOURCES_DIR="${EVO_CONFIG}/sources"
SIG_DIR="${EVO_CONFIG}/signatures"

NOTIFY_SCHEMA="org.gnome.evolution.plugin.mail-notification"

# ---------------------------------------------------------------------------
# 1. Make sure Evolution itself is installed.
# ---------------------------------------------------------------------------
install_evolution() {
  if command -v evolution >/dev/null 2>&1; then
    echo "Evolution already installed: $(evolution --version 2>&1 | head -1)"
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Warning: Evolution not found and this is not an apt-based system." >&2
    echo "         Install it with your package manager (e.g. dnf install evolution)." >&2
    return 0
  fi

  echo "Installing Evolution..."
  sudo apt-get update -qq
  sudo apt-get install -y evolution
  echo "Evolution installed: $(evolution --version 2>&1 | head -1)"
}

install_evolution

# ---------------------------------------------------------------------------
# 2. Deploy the shared assets to ~/common.
# ---------------------------------------------------------------------------
mkdir -p "${ASSET_DIR}"
cp -f "${ASSETS_SRC}/Felipe-Zarco-Assinatura.png" "${ASSET_DIR}/"
cp -f "${ASSETS_SRC}/yougotmail.ogg"              "${ASSET_DIR}/"
SIG_IMAGE="${ASSET_DIR}/Felipe-Zarco-Assinatura.png"
SOUND_FILE="${ASSET_DIR}/yougotmail.ogg"
echo "Assets deployed -> ${ASSET_DIR}"

# ---------------------------------------------------------------------------
# 3. Stop Evolution + evolution-data-server before touching its source files.
#    The source-registry daemon caches sources in memory and rewrites them on
#    exit, so edits made while it runs are silently lost. --force-shutdown stops
#    the client and every backend factory; they restart on the next launch and
#    reload the sources we write below.
# ---------------------------------------------------------------------------
if pgrep -x evolution >/dev/null 2>&1 \
   || pgrep -f evolution-source-registry >/dev/null 2>&1; then
  echo "Shutting down Evolution to apply configuration safely..."
  evolution --force-shutdown >/dev/null 2>&1 || true
  sleep 2
fi

# ---------------------------------------------------------------------------
# 4. Install the signature (source descriptor + HTML body with the correct
#    absolute image path). Backs up any existing body before overwriting.
# ---------------------------------------------------------------------------
mkdir -p "${SOURCES_DIR}" "${SIG_DIR}"

cp -f "${SIG_SOURCE_TMPL}" "${SOURCES_DIR}/${SIG_UID}.source"

sig_body="${SIG_DIR}/${SIG_UID}"
if [[ -f "${sig_body}" ]]; then
  cp "${sig_body}" "${sig_body}.bak.$(date +%Y%m%d-%H%M%S)"
fi
sed "s|__SIG_IMAGE__|${SIG_IMAGE}|g" "${SIG_HTML_TMPL}" > "${sig_body}"
echo "Signature 'Assinatura Zarco' installed (available, not applied by default)."

# ---------------------------------------------------------------------------
# 5. General preferences / panel layout.
# ---------------------------------------------------------------------------
if command -v dconf >/dev/null 2>&1; then
  dconf load /org/gnome/evolution/ < "${DCONF_FILE}"
  echo "Preferences / panel layout applied."
else
  echo "Warning: dconf not available; skipped preferences + sound." >&2
fi

# ---------------------------------------------------------------------------
# 6. New-mail notification sound — global, so every account uses it.
# ---------------------------------------------------------------------------
if command -v gsettings >/dev/null 2>&1; then
  gsettings set "${NOTIFY_SCHEMA}" notify-sound-enabled  true
  gsettings set "${NOTIFY_SCHEMA}" notify-sound-play-file true
  gsettings set "${NOTIFY_SCHEMA}" notify-sound-use-theme false
  gsettings set "${NOTIFY_SCHEMA}" notify-sound-beep      false
  gsettings set "${NOTIFY_SCHEMA}" notify-sound-file      "${SOUND_FILE}"
  echo "New-mail sound set -> ${SOUND_FILE}"
else
  echo "Warning: gsettings not available; skipped new-mail sound." >&2
fi

# ---------------------------------------------------------------------------
# 7. Link the signature to the company identity — ONLY if it already exists.
#    We look for a [Mail Identity] source whose Address is the company address
#    and set its SignatureUid. Personal accounts are never touched, so they
#    keep whatever signature (usually none) they already had.
# ---------------------------------------------------------------------------
link_signature() {
  local linked=0 f
  shopt -s nullglob
  for f in "${SOURCES_DIR}"/*.source; do
    grep -q '^\[Mail Identity\]'            "$f" || continue
    grep -q "^Address=${COMPANY_ADDRESS}$"  "$f" || continue

    awk -v uid="${SIG_UID}" '
      function flush() { if (insec && !done) { print "SignatureUid=" uid; done=1 } }
      /^\[/                       { flush(); insec = ($0 == "[Mail Identity]"); print; next }
      insec && /^SignatureUid=/   { print "SignatureUid=" uid; done=1; next }
                                  { print }
      END                         { flush() }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    linked=1
  done
  shopt -u nullglob

  if [[ ${linked} -eq 1 ]]; then
    echo "Signature linked to ${COMPANY_ADDRESS}."
  else
    echo "No ${COMPANY_ADDRESS} account present yet — signature stays available"
    echo "  but unlinked. Re-run this script after adding that account to link it."
  fi
}

link_signature

echo "Evolution configuration complete."
