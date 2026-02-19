#!/usr/bin/env bash

set -e

gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.mutter edge-tiling false
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
gsettings set org.gnome.mutter auto-maximize false
gsettings set org.gnome.desktop.interface font-name 'Bistream Charter 13'
echo "Install the 'Just Perfection' thingy here:"
echo
echo "https://extensions.gnome.org/extension/3843/just-perfection/"
echo

echo "Now set up fingerprint auth.  First, run this:"
echo
echo "   sudo pam-auth-update"
echo
echo "A TUI will show up - make sure 'fingerprint authentication' is checked"
echo "Somehow, you will not have to log out or reboot for this - try sudo somewhere to verify"
echo
echo "Next, we want more than one attempt at login with the fingerprint, since the reader"
echo "on the Framework sucks"
echo 
echo "edit (using sudo) /etc/pam.d/gdm-fingerprint"
echo 
echo "Find the line that looks like:"
echo
echo "auth	required	pam_fprintd.so"
echo
echo "add 'max-retries=5' at the end, so it looks like:"
echo
echo "auth	required	pam_fprintd.so max-retries=5"
echo










