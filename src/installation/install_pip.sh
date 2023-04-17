#!/bin/bash

# Usage: ensure_pip_pkg <PKG> <pip_UPDATE>
# Takes the name of a package to install if not already installed,
# and optionally a 1 if pip update should be run after installation
# has finished.
ensure_pip_pkg() {
  local pip_package_name="$1"
  local execute_pip_update="$2"

  # Determine if pip package is installed or not.
  local pip_pckg_exists
  pip_pckg_exists=$(
    pip list | grep -F "$pip_package_name"
    echo $?
  )

  # Install pip package if pip package is not yet installed.
  if [ "$pip_pckg_exists" == "1" ]; then
    yellow_msg " ${pip_package_name} is not installed. Installing now."
    #pip -y install "${pip_package_name}"
    pip install "${pip_package_name}" >>/dev/null 2>&1
  else
    green_msg " ${pip_package_name} is installed"
  fi

  verify_pip_installed "${pip_package_name}"

  if [ "$execute_pip_update" == "1" ]; then
    green_msg "Performing pip update"
    #pipenv update
  fi
}

# Verifies pip package is installed.
verify_pip_installed() {
  local pip_package_name="$1"

  # Determine if pip package is installed or not.
  local pip_pckg_exists
  pip_pckg_exists=$(
    pip list | grep -F "$pip_package_name"
    echo $?
  )

  # Throw error if pip package is not yet installed.
  if [ "$pip_pckg_exists" == "1" ]; then
    red_msg "Error, the pip package ${pip_package_name} is not installed."
    exit 3 # TODO: update exit status.
  else
    green_msg "Verified pip package ${pip_package_name} is installed."
  fi
}
