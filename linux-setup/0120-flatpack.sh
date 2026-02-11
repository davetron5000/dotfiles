#!/usr/bin/env bash

set -e

sudo apt update
sudo apt install --yes flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "[ $0 ] You gots to reboot"
