#!/usr/bin/env bash

set -e

sudo apt update && sudo apt install --yes git
git config --global user.name "Dave Copeland"
git config --global user.email "davec@naildrivin5.com"
git config --global init.defaultBranch main

sudo apt install git-delta
git config --global core.pager delta
git config --global delta.navigate true
git config --global delta.line-numbers true
git config --global interactive.diffFilter "delta --color-only"


