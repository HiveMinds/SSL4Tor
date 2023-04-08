#!/usr/bin/env bash

# 0.a Install prerequisites for Nextcloud.
# 0.b Verify prerequisites for Nextcloud are installed.
apt_remove() {
  local apt_package_name="$1"
  yellow_msg "Removing ${apt_package_name}...\\n"
  sudo apt purge "$apt_package_name" -y

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
  )

  # Throw error if package still is installed.
  if [ "$apt_pckg_exists" == "1" ]; then
    printf "==========================\\n"
    green_msg "Verified the apt package ${apt_package_name} is removed.\\n"
    printf "==========================\\n\\n"
  else
    printf "======================\\n"
    red_msg "Error, the apt package ${apt_package_name} is still installed.\\n"
    printf "======================\\n"
    exit 3 # TODO: update exit status.
  fi
}

##################################################################
# Purpose: Clean up APT environment
# Arguments:
#   None
##################################################################
function cleanup() {
  sudo apt clean

  # Auto remove any remaining unneeded apt packages.
  sudo apt autoremove

  # Fix any remaining broken installations.
  sudo apt -f install
}
