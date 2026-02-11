#!/usr/bin/env bash

set -e
set -u
set -o pipefail

firefoxpwa profile create --name "Mastodon" --description "Mastodon" > /tmp/output 2>&1
grep 'Profile created' /tmp/output | sed 's/^.*Profile created: //g' > /tmp/profile_id
profile_id=$(cat /tmp/profile_id)
firefoxpwa site install --profile "${profile_id}" --launch-now --name "Mastodon" https://ruby.social/manifest.json
