#!/bin/bash

generate_onion_domain() {
  local project_name="$1"
  local hidden_service_port="$2"
  local local_project_port="$3"

  ensure_apt_pkg "tor" 1
  prepare_onion_domain_creation "$project_name" "$hidden_service_port" "$local_project_port"
}

prepare_onion_domain_creation() {
  local project_name="$1"
  local hidden_service_port="$2"
  local local_project_port="$3"

  # TODO: include verify_apt_installedin project.
  verify_apt_installed "tor"

  # Verify tor configuration file exists (Should be created at installation of
  # sudo apt tor).
  manual_assert_file_exists "$TORRC_FILEPATH" "true"

  #Create the project dir for the onion domain and verify it exists.
  sudo mkdir -p "$TOR_SERVICE_DIR/$project_name"
  manual_assert_dir_exists "$TOR_SERVICE_DIR/$project_name" "true"

  # Create the hostname file for the onion domain and verify it exists.
  sudo touch "$TOR_SERVICE_DIR/$project_name/hostname"
  manual_assert_file_exists "$TOR_SERVICE_DIR/$project_name/hostname" "true"

  local torrc_line_1
  torrc_line_1="HiddenServiceDir $TOR_SERVICE_DIR/$project_name/"
  local torrc_line_2
  torrc_line_2="HiddenServicePort $hidden_service_port 127.0.0.1:$local_project_port"

  # E. If that content is not in the torrc file, append it at file end.
  append_lines_if_not_found "$torrc_line_1" "$torrc_line_2" "$TORRC_FILEPATH"

  # F. Verify that content is in the file.
  verify_has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$TORRC_FILEPATH"
}

start_onion_domain_creation() {
  local project_name="$1"

  # Make root owner of tor directory.
  sudo chown -R root /var/lib/tor
  sudo chmod 700 "/var/lib/tor/$project_name"

  # Start "sudo tor" in the background
  sudo tor | tee "$TOR_LOG_FILEPATH" >/dev/null

  # Set the start time of the function
  start_time=$(date +%s)

  # Check if the onion URL exists in the hostname every 5 seconds, until 2 minutes have passed
  while true; do
    local onion_exists
    onion_exists=$(check_onion_url_exists_in_hostname "$TOR_SERVICE_DIR/$project_name/hostname")

    # Check if the onion URL exists in the hostname
    if [[ "$onion_exists" -eq 0 ]]; then
      # If the onion URL exists, terminate the "sudo tor" process and return 0
      pkill -f "sudo tor"
      return 0
    fi

    sleep 1

    # Calculate the elapsed time from the start of the function
    elapsed_time=$(($(date +%s) - start_time))

    # If 2 minutes have passed, raise an exception and return 7
    if ((elapsed_time > 120)); then
      pkill -f "sudo tor"
      echo >&2 "Error: Onion URL does not exist in hostname after 2 minutes."
      return 7
    fi

    # Wait for 5 seconds before checking again
    sleep 5
  done

}
