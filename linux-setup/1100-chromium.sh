#!/usr/bin/env bash

set -e

sudo apt update
sudo apt remove --yes chromium-browser
sudo apt remove --yes chromium
flatpak install flathub org.chromium.Chromium
xdg-settings set default-web-browser firefox.desktop
