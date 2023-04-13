#!/bin/bash

delete_onion_domain() {
  # local project_name="$1"
  apt_remove "tor" 1
  apt_remove "net-tools" 1
  apt_remove "httping" 1
  remove_onion_domain_files # "$project_name"
}
remove_onion_domain_files() {
  # local project_name="$1"

  # After uninstalling tor, this file should not exist anymore.
  manual_assert_file_not_exists "$TORRC_FILEPATH" "true"

  # Do not delete keys directory, (nor files lock,state).
  # Delete the project dir for the onion domains.
  for dir_path in "$TOR_SERVICE_DIR/"*; do
    echo "dir_path=$dir_path"
    local dir_name=${dir_path##*/}
    echo "dir_name=$dir_name"
    # TODO: get the last element in the array. And check if that is not equal to keys.
    # Then delete that directory.
    if [ "$dir_name" != "keys" ]; then
      read -p "Deleting:$dir_name"
      sudo rm -rf "$TOR_SERVICE_DIR/$dir_name"
      manual_assert_dir_not_exists "$TOR_SERVICE_DIR/$dir_name" "true"
      manual_assert_file_not_exists "$TOR_SERVICE_DIR/$dir_name/hostname" "true"
    fi
  done

  # Create the project dir for the onion domain and verify it exists.
  # sudo rm -rf "$TOR_SERVICE_DIR/$project_name"
  # manual_assert_dir_not_exists "$TOR_SERVICE_DIR/$project_name" "true"
  #
  # Create the hostname file for the onion domain and verify it exists.TORRC_FILEPATH
  # sudo rm -rf "$TOR_SERVICE_DIR/$project_name/hostname"
  # manual_assert_file_not_exists "$TOR_SERVICE_DIR/$project_name/hostname" "true"
}
