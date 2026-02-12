#!/usr/bin/env bash

set -e
set -u
set -o pipefail

app_name=$1

firefoxpwa profile list | grep -1 "${app_name}" | grep ID: | sed 's/^ID: //' > /tmp/configure-profile || (echo "Cannot find profile for ${app_name}"; exit 1)
profile=$(cat /tmp/configure-profile)
if [ -z "${profile}" ]; then
  echo "No profile"
  exit 1
fi

firefoxpwa profile list | grep "${app_name}" | grep manifest | sed 's/^.*https:\/\///' | sed 's/\/.*$//' > /tmp/configure-domain || (echo "Cannot figure out domain name for ${app_name}"; exit 1)
domain=$(cat /tmp/configure-domain)

echo $profile
echo $domain,*.$domain

profile_dir=~/.local/share/firefoxpwa/profiles/${profile}
prefs_file=${profile_dir}/user.js

if [ -d "${profile_dir}" ] ; then
  if [ -f "${prefs_file}" ]; then
    echo "${prefs_file} exists - not overwriting. Delete it and re-run this script"
    exit 1
  else
    echo "Writing to ${prefs_file}"
    echo "user_pref(\"firefoxpwa.allowedDomains\", \"${domain},*.${domain}\");" > "${prefs_file}"
    echo 'user_pref("firefoxpwa.launchType", 3);' >> "${prefs_file}"
    echo 'user_pref("firefoxpwa.openOutOfScopeInDefaultBrowser", true);' >> "${prefs_file}"
    echo 'user_pref("signon.rememberSignons", false);' >> "${prefs_file}"

    echo "All done - restart the app"
  fi
else
  echo "Profile dir '${profile_dir}' doesn't exist - you may need to run the app once"
  exit 1
fi

