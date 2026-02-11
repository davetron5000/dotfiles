#!/usr/bin/env bash

set -e

sudo add-apt-repository universe -y 
sudo add-apt-repository ppa:agornostal/ulauncher  -y
sudo apt update 
sudo apt install --yes ulauncher

echo "[ $0 ] Now go install https://extensions.gnome.org/extension/6385/steal-my-focus-window/"
