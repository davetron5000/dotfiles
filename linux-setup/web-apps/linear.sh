
#!/usr/bin/env bash

set -e
set -u
set -o pipefail

firefoxpwa profile create --name "Linear" --description "Linear" > /tmp/output 2>&1
grep 'Profile created' /tmp/output | sed 's/^.*Profile created: //g' > /tmp/profile_id
profile_id=$(cat /tmp/profile_id)
firefoxpwa site install --profile "${profile_id}" --launch-now --name "Linear" https://linear.app/static/pwa.webmanifest






