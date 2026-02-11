#!/usr/bin/env bash

set -e
set -u
set -o pipefail

echo "[ $0 ] Ensuring Neovim not installed via apt"
sudo apt update
sudo apt remove neovim

# From https://neovim.io/doc/install/
file=nvim-linux-x86_64
tarball=${file}.tar.gz
install=/opt/${file}/bin/nvim
url=https://github.com/neovim/neovim/releases/latest/download/${tarball}

rm -rf "${tarball}"

echo "[ $0 ] Downloading from ${url}"
curl -LO "${url}"
echo "[ $0 ] Extracting to /top"
sudo tar -C /opt -xf "${tarball}"
echo "[ $0 ] Checking that it went into ${install}"
if [ -f "${install}" ]; then
  echo "[ $0 ] Symlink for great glory"
  sudo ln -s ${install} /usr/local/bin/neovide
  rm "${tarball}"
else
  echo "[ $0 ] It did not"
  ls /opt
  exit 1
fi
