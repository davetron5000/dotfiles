#!/usr/bin/env bash

set -e
set -u
set -o pipefail

firefoxpwa profile create --name "Devdocs" --description "Devdocs" > /tmp/output 2>&1
grep 'Profile created' /tmp/output | sed 's/^.*Profile created: //g' > /tmp/profile_id
profile_id=$(cat /tmp/profile_id)
firefoxpwa site install --profile "${profile_id}" --launch-now --name "Devdocs" https://devdocs.io/manifest.json
echo "You must make sure that the FirefoxPWA extension has 'automatic web launching' set"
echo "When it is, you must then manually go into devdocs preferences and set 'Launch this web app on matching website'"

