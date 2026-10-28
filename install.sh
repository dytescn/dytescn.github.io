#!/usr/bin/env sh
set -eu

case "$(uname -s)" in
  Darwin) os="macos" ;;
  Linux) os="linux" ;;
  *)
    echo "dytes: unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

install_dir="${DYTES_INSTALL_DIR:-$HOME/.local/bin}"
url="https://github.com/dytescn/dytes/releases/latest/download/dytes-$os"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "Downloading dytes for $os..."
curl -fsSL "$url" -o "$tmp"
chmod +x "$tmp"
mkdir -p "$install_dir"
mv "$tmp" "$install_dir/dytes"
trap - EXIT

if [ "$os" = "macos" ]; then
  xattr -d com.apple.quarantine "$install_dir/dytes" 2>/dev/null || true
fi

echo "Installed: $install_dir/dytes"
case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) echo "Add $install_dir to PATH, then run: dytes --version" ;;
esac
