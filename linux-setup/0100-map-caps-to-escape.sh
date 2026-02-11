#!/usr/bin/env bash
set -euo pipefail

KB_FILE=/etc/default/keyboard

if grep -q '^XKBOPTIONS=' "$KB_FILE"; then
  echo "Augmenting XKBOPTIONS in ${KB_FILE}"
  sudo sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="caps:escape"/' "$KB_FILE"
else
  echo "No existing XKBOPTIONS"
  echo 'XKBOPTIONS="caps:escape"' | sudo tee -a "$KB_FILE" > /dev/null
fi

sudo dpkg-reconfigure -f noninteractive keyboard-configuration
sudo setupcon -K || true
