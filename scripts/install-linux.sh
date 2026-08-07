#!/bin/sh
#
# OpenBike Linux installer.
#
#   curl -fsSL https://github.com/HugoLeBoennec/OpenBike/releases/latest/download/install.sh | sh
#
# Installs the release tarball into the user's XDG directories. No root, no
# package manager, nothing written outside $HOME. To remove it again:
#
#   curl -fsSL .../install.sh | sh -s -- --uninstall
#
# Why a script rather than an AppImage: the release bundle already ships a
# correctly laid out hicolor icon theme and a .desktop entry (see the install()
# rules in linux/CMakeLists.txt), so all that is missing from a plain tarball
# is copying those two trees where the desktop environment looks for them.
# See docs/release/desktop-distribution.md.
#
# Deliberately POSIX sh, and deliberately reads nothing from stdin — stdin is
# the script itself when this is piped from curl, so a prompt here would
# consume the script's own remaining text.

set -eu

REPO="HugoLeBoennec/OpenBike"
TARBALL="OpenBike-linux-x64.tar.gz"
CHECKSUMS="SHA256SUMS"
BIN_NAME="open_bike"
APP_ID="run.records.openbike"
CMD_NAME="openbike"

XDG_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_DIR="$XDG_DATA/openbike"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$XDG_DATA/applications"
ICON_DIR="$XDG_DATA/icons/hicolor"

VERSION="latest"
DO_UNINSTALL=0

say()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<EOF
OpenBike Linux installer

Usage: install.sh [options]

  --version <tag>   Release tag to install (default: latest), e.g. v1.0.0
  --uninstall       Remove an existing installation
  -h, --help        Show this message

Installs to:
  $INSTALL_DIR
  $BIN_DIR/$CMD_NAME
  $DESKTOP_DIR/$APP_ID.desktop
  $ICON_DIR/*/apps/$APP_ID.png
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --version) [ $# -ge 2 ] || die "--version needs a value"; VERSION="$2"; shift 2 ;;
    --uninstall) DO_UNINSTALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

# --- uninstall ---------------------------------------------------------------

if [ "$DO_UNINSTALL" -eq 1 ]; then
  rm -rf "$INSTALL_DIR"
  rm -f "$BIN_DIR/$CMD_NAME"
  rm -f "$DESKTOP_DIR/$APP_ID.desktop"
  # Only ever remove icons matching this app id, never a whole theme directory.
  find "$ICON_DIR" -name "$APP_ID.png" -type f -delete 2>/dev/null || true
  command -v update-desktop-database >/dev/null 2>&1 &&
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  say "OpenBike removed."
  exit 0
fi

# --- fetch -------------------------------------------------------------------

if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -qO "$2" "$1"; }
else
  die "need curl or wget"
fi

if [ "$VERSION" = "latest" ]; then
  BASE="https://github.com/$REPO/releases/latest/download"
else
  BASE="https://github.com/$REPO/releases/download/$VERSION"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

say "Downloading OpenBike ($VERSION)..."
fetch "$BASE/$TARBALL" "$TMP/$TARBALL" || die "could not download $BASE/$TARBALL"

# --- verify ------------------------------------------------------------------
#
# SHA256SUMS is published alongside the tarball and names it exactly, so the
# stock -c mode works without rewriting the file. Linux has no OS-level
# signature check on a direct download, so this is the whole integrity story;
# a failure here is fatal rather than a warning.

if fetch "$BASE/$CHECKSUMS" "$TMP/$CHECKSUMS" 2>/dev/null; then
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$TMP" && sha256sum -c "$CHECKSUMS" >/dev/null 2>&1) ||
      die "checksum mismatch on $TARBALL — refusing to install"
    say "Checksum OK."
  elif command -v shasum >/dev/null 2>&1; then
    (cd "$TMP" && shasum -a 256 -c "$CHECKSUMS" >/dev/null 2>&1) ||
      die "checksum mismatch on $TARBALL — refusing to install"
    say "Checksum OK."
  else
    warn "no sha256sum or shasum available; skipping checksum verification"
  fi
else
  warn "no $CHECKSUMS published for this release; skipping verification"
fi

# --- install -----------------------------------------------------------------

say "Installing to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"
tar xzf "$TMP/$TARBALL" -C "$INSTALL_DIR"

[ -x "$INSTALL_DIR/$BIN_NAME" ] || die "$BIN_NAME missing from the tarball"

ln -sf "$INSTALL_DIR/$BIN_NAME" "$BIN_DIR/$CMD_NAME"

# The shipped entry has a bare `Exec=open_bike`, which only resolves if
# ~/.local/bin is on PATH — and desktop launchers frequently start from an
# environment where it is not. Point the installed copy at the real path.
SRC_DESKTOP="$INSTALL_DIR/data/applications/$APP_ID.desktop"
if [ -f "$SRC_DESKTOP" ]; then
  sed "s|^Exec=.*|Exec=$INSTALL_DIR/$BIN_NAME|" "$SRC_DESKTOP" \
    > "$DESKTOP_DIR/$APP_ID.desktop"
  chmod 644 "$DESKTOP_DIR/$APP_ID.desktop"
else
  warn "no .desktop entry in the tarball; skipping menu entry"
fi

if [ -d "$INSTALL_DIR/data/icons/hicolor" ]; then
  # cp -R of the theme root would clobber the user's index.theme; copy only
  # the per-size app icons this package owns.
  (cd "$INSTALL_DIR/data/icons/hicolor" && find . -name "$APP_ID.png" -type f) |
  while IFS= read -r rel; do
    mkdir -p "$ICON_DIR/$(dirname "$rel")"
    cp "$INSTALL_DIR/data/icons/hicolor/$rel" "$ICON_DIR/$rel"
  done
else
  warn "no icon theme in the tarball; skipping icons"
fi

command -v update-desktop-database >/dev/null 2>&1 &&
  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
command -v gtk-update-icon-cache >/dev/null 2>&1 &&
  gtk-update-icon-cache -qtf "$ICON_DIR" 2>/dev/null || true

# --- report ------------------------------------------------------------------
#
# Nothing above installs system libraries, so report anything the dynamic
# linker cannot resolve rather than letting it surface as a silent failure to
# start. ldd is authoritative here in a way a hardcoded package list is not.

if command -v ldd >/dev/null 2>&1; then
  MISSING="$(
    { ldd "$INSTALL_DIR/$BIN_NAME" 2>/dev/null
      for so in "$INSTALL_DIR"/lib/*.so; do
        [ -e "$so" ] && ldd "$so" 2>/dev/null
      done
    } | awk '/not found/ { print $1 }' | sort -u
  )"
  if [ -n "$MISSING" ]; then
    warn "these shared libraries are missing on this system:"
    printf '  %s\n' $MISSING >&2
    warn "install your distro's packages for them (commonly libgtk-3-0,"
    warn "libsecret-1-0, libjsoncpp, libcurl) — OpenBike will not start without them."
  fi
fi

say ""
say "OpenBike installed."
say "  Run:       $CMD_NAME"
say "  Uninstall: curl -fsSL $BASE/install.sh | sh -s -- --uninstall"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) say ""
     warn "$BIN_DIR is not on your PATH — the menu entry works, but the"
     warn "'$CMD_NAME' command will not until you add it to your shell profile." ;;
esac
