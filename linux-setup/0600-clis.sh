
#!/usr/bin/env bash

set -e

sudo apt update
sudo apt install --yes direnv \
                       eza \
                       silversearcher-ag \
                       btop \
                       tig \
                       tree \
                       jq \
                       bat

