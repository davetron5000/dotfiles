#!/usr/bin/env bash

set -e

gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.mutter edge-tiling false
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
gsettings set org.gnome.mutter auto-maximize false






