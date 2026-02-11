set -e
curl -L -o espanso.deb 'https://github.com/espanso/espanso/releases/latest/download/espanso-debian-wayland-amd64.deb'
sudo apt install ./espanso.deb
sudo setcap "cap_dac_override+p" $(which espanso)
espanso service register
espanso start
echo "Edit /home/davec/.config/espanso/match/base.yml"


