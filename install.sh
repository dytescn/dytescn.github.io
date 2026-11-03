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
base="${DYTES_DOWNLOAD_BASE:-https://packages.funxdata.com/core/dytes}"
url="$base/latest/$os/dytes"
target="$install_dir/dytes"
tmp="$install_dir/.dytes.download.$$"
checksum_tmp="$install_dir/.dytes.sha256.$$"

mkdir -p "$install_dir"
trap 'rm -f "$tmp" "$checksum_tmp"' EXIT INT TERM

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

echo "Downloading dytes for $os from packages.funxdata.com..."
attempt=1
while [ "$attempt" -le 3 ]; do
  if curl -fL --retry 3 --retry-delay 2 --retry-connrefused \
      --connect-timeout 15 --max-time 900 \
      --progress-bar "$url" -o "$tmp"; then
    break
  fi
  echo "Download failed (attempt $attempt/3), retrying..." >&2
  attempt=$((attempt + 1))
  sleep 2
done
if [ "$attempt" -gt 3 ]; then
  echo "dytes: download failed after 3 attempts: $url" >&2
  exit 1
fi

if curl -fsSL --max-time 30 "$url.sha256" -o "$checksum_tmp" 2>/dev/null; then
  expected="$(awk 'NR == 1 {print $1}' "$checksum_tmp")"
  actual="$(sha256_of "$tmp")"
  if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
    echo "dytes: SHA-256 mismatch (expected $expected, got $actual)" >&2
    exit 1
  fi
  echo "SHA-256 verified"
else
  echo "Warning: checksum unavailable, skipping verification" >&2
fi

chmod +x "$tmp"
mv -f "$tmp" "$target"
trap - EXIT INT TERM
rm -f "$checksum_tmp"

if [ "$os" = "macos" ]; then
  xattr -d com.apple.quarantine "$target" 2>/dev/null || true
fi

echo "Installed: $target"
case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) echo "Add $install_dir to PATH, then run: dytes --version" ;;
esac
