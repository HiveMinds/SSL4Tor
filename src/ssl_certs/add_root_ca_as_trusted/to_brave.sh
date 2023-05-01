#!/bin/bash
# Adds the root ca certificate named ca.crt to the brave browser.

get_brave_policies_path() {
  local policies_filepath
  policies_filepath="/etc/brave/managed/policies.json"
  sudo mkdir -p "/etc/brave/managed/"
  echo "$policies_filepath"
}
