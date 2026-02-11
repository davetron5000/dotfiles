
#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# From https://neovim.io/doc/install/
file=neovide-linux-x86_64
tarball=${file}.tar.gz
install=/opt/neovide
url=https://github.com/neovide/neovide/releases/download/0.15.2/${tarball}
usr_local=/usr/local/bin/neovide

if [ -f "${usr_local}" ]; then
  echo "[ $0 ] Already installed - not re-installing"
else
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
fi
echo "[ $0 ] Setting up the app icon"
local_app=~/.local/share/applications
desktop="${local_app}/neovide.desktop"
icons_base=~/.local/share/icons/hicolor
icons="${icons_base}"/scalable/apps

mkdir -p ${local_app}
mkdir -p ${icons}

echo "[Desktop Entry]" > ${desktop}
echo "Name=Neovide"                      >> ${desktop}
echo "Exec=/usr/local/bin/neovide"       >> ${desktop}
echo "Icon=neovide"                      >> ${desktop}
echo "Type=Application"                  >> ${desktop}
echo "Categories=Development;TextEditor" >> ${desktop}

icon_url=https://raw.githubusercontent.com/neovide/neovide/7a3f56830caf671ad884caff4990741336282a1e/assets/neovide.svg

curl -L -o "${icons}/neovide.svg" "${icon_url}"

update-desktop-database "${local_app}"
if [ -f "${icons_base}/index.theme" ]; then
  gtk-update-icon-cache "${icons_base}"
else
  gtk-update-icon-cache "${icons_base}" || echo "Theme not there, but clanker says that's fine"
fi

echo "You need to log out and back in again FFS"
