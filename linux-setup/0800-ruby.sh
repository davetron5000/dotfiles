#!/usr/bin/env bash

set -e
set -u
set -o pipefail

sudo apt update
sudo apt install --yes ruby-full

