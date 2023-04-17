#!/usr/bin/env bash

# 0.a Install prerequisites for Nextcloud.
# 0.b Verify prerequisites for Nextcloud are installed.
apt_remove() {
  local apt_package_name="$1"

  yellow_msg "Removing ${apt_package_name} if it is installed."

  sudo apt purge "$apt_package_name" -y >>/dev/null 2>&1

  verify_apt_removed "$apt_package_name"
}

apt_is_installed() { 
  local apt_package_name="$1"
    dpkg -l $1 &> /dev/null
    if [ $? -eq 0 ]; then
        echo "FOUND"
    else
        echo "NOTFOUND"
    fi
}


# Verifies apt package is removed
verify_apt_removed() {
  local apt_package_name="$1"

  # Throw error if package still is installed.
  if [[ "($apt_is_installed "$apt_package_name")" == "NOTFOUND" ]]; then
    green_msg "Verified the apt package ${apt_package_name} is removed."
  else
    red_msg "Error, the apt package ${apt_package_name} is still installed."
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
