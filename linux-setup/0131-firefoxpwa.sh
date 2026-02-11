#!/usr/bin/env bash

set -e

# Set up FirefoxPWAs
# Install required packages for third-party repositories
sudo apt update
sudo apt install debian-archive-keyring # Debian-only
sudo apt install curl gpg apt-transport-https

# Make sure the keyrings directory exists
sudo install -m 0755 -d /etc/apt/keyrings

# Import the GPG key and enable the repository
curl -fsSL https://packagecloud.io/filips/FirefoxPWA/gpgkey | gpg --dearmor | sudo tee /etc/apt/keyrings/firefoxpwa.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/firefoxpwa.gpg] https://packagecloud.io/filips/FirefoxPWA/any any main" | sudo tee /etc/apt/sources.list.d/firefoxpwa.list > /dev/null

# Refresh repositories and install the package
sudo apt update
sudo apt install firefoxpwa
firefoxpwa runtime install
