#!/usr/bin/env bash

set -e

curl -LO https://github.com/xremap/xremap/releases/download/v0.14.3/xremap-linux-x86_64-gnome.zip
unzip xremap-linux-x86_64-gnome.zip
mkdir -p ~/.local/bin
mv xremap ~/.local/bin
echo "#!/usr/bin/env bash" > ~/.local/bin/xremap-wrap.sh
echo "/home/davec/.local/bin/xremap --watch /home/davec/.config/xremap/xremap.yml" >> ~/.local/bin/xremap-wrap.sh
chmod +x ~/.local/bin/xremap-wrap.sh
rm xremap-linux-x86_64-gnome.zip
open https://extensions.gnome.org/extension/5060/xremap/
sudo gpasswd -a "$USER" input
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
echo "You must now fucking reboot"
mkdir -p ~/.config/xremap
mkdir -p ~/.config/autostart
echo "[Desktop Entry]" > ~/.config/autostart/xremap.desktop
echo "Name=xremap" >> ~/.config/autostart/xremap.desktop
echo "Type=Application" >> ~/.config/autostart/xremap.desktop
echo "Exec=/home/davec/.local/bin/xremap-wrap.sh" >> ~/.config/autostart/xremap.desktop
echo "X-GNOME-Autostart-enabled=true" >> ~/.config/autostart/xremap.desktop
chmod +x ~/.config/autostart/xremap.desktop
echo "Copy your xremap.yml to ~/.config/xremap/"
