#!/bin/bash

# TODO: write check to see if onion domain is already in torrc.
# TODO: make the torrc content recognisable, and modular, with comment blocks.

#######################################
# Checks whether the onion domain already exists for this project name.
#
# Local variables:
#  - filepath: path to the file to verify
#
# Globals:
#  None.
# Arguments:
#  - $1: filepath to verify
#
# Returns:
#  0 if the file exists and has a valid onion URL as its content
#  7 if the file does not exist
#  8 if the file exists, but its content is not a valid onion URL
# Outputs:
#  None.
#######################################
check_onion_url_exists_in_hostname() {
  local project_name="$1"

  local file_content
  file_content=$(sudo cat "$TOR_SERVICE_DIR/$project_name/hostname")

  # Verify that the file exists
  if sudo test -f "$TOR_SERVICE_DIR/$project_name/hostname"; then
    # Verify that the file's content is a valid onion URL
    if [[ "$file_content" =~ ^[a-z0-9]{56}\.onion$ ]]; then
      echo "FOUND" # file exists and has valid onion URL as its content
    else
      echo "NOTFOUND" # file exists, but has invalid onion URL as its content
    fi
  else
    echo "NOTFOUND" # file does not exist
  fi
}
