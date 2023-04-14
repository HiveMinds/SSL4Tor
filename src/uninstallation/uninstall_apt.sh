#!/usr/bin/env bash

# 0.a Install prerequisites for Nextcloud.
# 0.b Verify prerequisites for Nextcloud are installed.
apt_remove() {
  local apt_package_name="$1"
  printf "==========================\\n"
  yellow_msg "Removing ${apt_package_name} if it is installed."
  printf "\\n==========================\\n"
  sudo apt purge "$apt_package_name" -y >>/dev/null 2>&1

  verify_apt_removed "$apt_package_name"
}

# Verifies apt package is removed
verify_apt_removed() {
  local apt_package_name="$1"

  # Determine if apt package is installed or not.
  local apt_pckg_exists
  apt_pckg_exists=$(
    dpkg-query -W --showformat='${status}\n' "${apt_package_name}" | grep "ok installed"
    echo $?
  ) >>/dev/null 2>&1

  # Throw error if package still is installed.
  if [[ "$apt_pckg_exists" == "1" ]]; then
    printf "==========================\\n"
    green_msg "Verified the apt package ${apt_package_name} is removed."
    printf "\\n==========================\\n"
  else
    printf "==========================\\n"
    red_msg "Error, the apt package ${apt_package_name} is still installed."
    printf "\\n==========================\\n"
    exit 3 # TODO: update exit status.
  fi
}

##################################################################
# Purpose: Clean up APT environment
# Arguments:
#   None
##################################################################
function cleanup() {
  sudo apt clean >/dev/null

  # Auto remove any remaining unneeded apt packages.
  sudo apt autoremove >>/dev/null 2>&1

  # Fix any remaining broken installations.
  sudo apt -f install >>/dev/null 2>&1
}
