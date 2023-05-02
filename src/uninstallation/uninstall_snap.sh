#!/usr/bin/env bash

# 0.a Install prerequisites for Nextcloud.
# 0.b Verify prerequisites for Nextcloud are installed.
snap_remove() {
  local snap_package_name="$1"

  yellow_msg "Removing ${snap_package_name} if it is installed."

  sudo snap remove --purge "$snap_package_name" >>/dev/null 2>&1

  verify_snap_removed "$snap_package_name"
}

snap_package_is_installed() {
  local app_name="$1"
  respons_lines="$(snap list "$app_name" 2>/dev/null)"
  local found_app
  found_app=$(command_output_contains "$app_name" "${respons_lines}")
  echo "$found_app"
}

# Verifies snap package is removed
verify_snap_removed() {
  local snap_package_name="$1"

  # Throw error if package still is installed.
  if [[ "$(snap_package_is_installed "$snap_package_name")" == "NOTFOUND" ]]; then
    green_msg "Verified the snap package ${snap_package_name} is removed."
  else
    red_msg "Error, the snap package ${snap_package_name} is still installed."
    exit 3 # TODO: update exit status.
  fi
}
