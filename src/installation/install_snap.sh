#!/usr/bin/env bash

# Usage: ensure_apt_pkg <PKG> <APT_UPDATE>
# Takes the name of a package to install if not already installed,
# and optionally a 1 if apt update should be run after installation
# has finished.
ensure_snap_pkg() {
  local snap_package_name="${1}"

  # Install snap package if snap package is not yet installed.
  if [[ "$(snap_package_is_installed "$snap_package_name")" != "FOUND" ]]; then
    yellow_msg " ${snap_package_name} is not installed. Installing now."
    sudo snap install "${snap_package_name}" >>/dev/null 2>&1
  else
    green_msg " ${snap_package_name} is installed"
  fi

  verify_snap_installed "${snap_package_name}"
}

# Verifies snap package is installed.
verify_snap_installed() {
  local snap_package_name="$1"

  # Throw error if snap package is not yet installed.
  if [[ "$(snap_package_is_installed "$snap_package_name")" != "FOUND" ]]; then
    red_msg "Error, the snap package ${snap_package_name} is not installed."
    exit 3 # TODO: update exit status.
  else
    green_msg "Verified snap package ${snap_package_name} is installed."
  fi
}
