#!/bin/bash

delete_onion_domain() {
  local project_name="$1"

  apt_remove "tor" 1
  remove_onion_domain_files "$project_name"

}
remove_onion_domain_files() {
  local project_name="$1"

  # After uninstalling tor, this file should not exist anymore.
  manual_assert_file_not_exists "$TORRC_FILEPATH" "true"

  #Create the project dir for the onion domain and verify it exists.
  sudo rm -rf "$TOR_SERVICE_DIR/$project_name"
  manual_assert_dir_not_exists "$TOR_SERVICE_DIR/$project_name" "true"

  # Create the hostname file for the onion domain and verify it exists.
  sudo rm -rf "$TOR_SERVICE_DIR/$project_name/hostname"
  manual_assert_file_not_exists "$TOR_SERVICE_DIR/$project_name/hostname" "true"
}
