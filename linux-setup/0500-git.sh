#!/usr/bin/env bash

set -e

sudo apt update && sudo apt install --yes git
git config --global user.name "Dave Copeland"
git config --global user.email "davec@naildrivin5.com"
git config --global init.defaultBranch main

