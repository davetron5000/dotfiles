#!/usr/bin/env bash

set -e
set -u
set -o pipefail

FONT_URLS=(
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Monofur.zip"
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip"
  "https://dl.dafont.com/dl/?f=monofur"
)

FONT_DIR="${HOME}/.local/share/fonts"
TMP_DIR=$(mktemp -d)
mkdir -p "${FONT_DIR}"

for url in "${FONT_URLS[@]}"; do
  filename=$(basename "${url}")
  echo "[ $0 ] Downloading ${filename}"
  curl -L -o "${TMP_DIR}/${filename}" "${url}"

  echo "[ $0 ] Extracting ${filename}"
  unzip -o -q "${TMP_DIR}/${filename}" "*.ttf" -d "${FONT_DIR}" 2>/dev/null || true
done

echo "[ $0 ] Rebuilding font cache"
fc-cache -fv

rm -rf "${TMP_DIR}"

