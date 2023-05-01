#!/bin/bash
# Adds the root ca certificate named ca.crt to the apt or snap installation of Firefox.

firefox_is_installed() {
  if [[ "$(app_is_installed_with_apt "firefox")" == "FOUND" ]]; then
    echo "FOUND"
  elif [[ "$(app_is_installed_with_snap "firefox")" == "FOUND" ]]; then
    echo "FOUND"
    echo "ERROR, snap Firefox is not yet supported."
    exit 5
  else
    echo "NOTFOUND"
  fi
}

get_firefox_policies_path() {
  local policies_filepath

  #elif snap list | grep -v firefox &>/dev/null; then
  if [ "$(firefox_via_snap)" == "FOUND" ]; then
    # policies_filepath="/snap/firefox/current/distribution/policies.json"
    policies_filepath="/etc/firefox/policies/policies.json"
  # TODO: prevent False positive on apt package if snap Firefox is installed.
  elif [[ "$(apt_package_is_installed "Firefox")" != "FOUND" ]]; then
    #if dpkg -l firefox &>/dev/null; then
    policies_filepath="/etc/firefox/policies/policies.json"
  else
    echo "Error, firefox installation was not found."
    exit 6
  fi
  sudo mkdir -p "/etc/firefox/policies"
  echo "$policies_filepath"
}
