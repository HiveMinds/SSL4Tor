#!/bin/bash

add_service_to_torrc() {
  local project_name="$1"
  local local_project_port="$2"
  local public_port_to_access_onion="$3"

  assert_is_non_empty_string "$public_port_to_access_onion"
  assert_is_non_empty_string "$local_project_port"

  create_torrc_lines_one_onion_per_service "$project_name" "$local_project_port" "$public_port_to_access_onion"
  prepare_onion_domain_creation "$project_name" "$local_project_port" "$public_port_to_access_onion"
}

create_torrc_lines_one_onion_per_service() {
  local project_name="$1"
  local local_project_port="$2"
  local public_port_to_access_onion="$3"

  local torrc_line_1
  torrc_line_1="HiddenServiceDir $TOR_SERVICE_DIR/$project_name/"
  local torrc_line_2

  assert_is_non_empty_string "$public_port_to_access_onion"
  torrc_line_2="HiddenServicePort $public_port_to_access_onion 127.0.0.1:$local_project_port"

  # E. If that content is not in the torrc file, append it at file end.
  append_lines_if_not_found "$torrc_line_1" "$torrc_line_2" "$TORRC_FILEPATH"

  # F. Verify that content is in the file.
  verify_has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$TORRC_FILEPATH"
}

prepare_onion_domain_creation() {
  local project_name="$1"
  local local_project_port="$2"
  local public_port_to_access_onion="$3"

  # Verify tor configuration file exists (Should be created at installation of
  # sudo apt tor).
  manual_assert_file_exists "$TORRC_FILEPATH" "true"

  #Create the project dir for the onion domain and verify it exists.
  sudo mkdir -p "$TOR_SERVICE_DIR/$project_name"
  manual_assert_dir_exists "$TOR_SERVICE_DIR/$project_name" "true"

  # Create the hostname file for the onion domain and verify it exists.
  sudo touch "$TOR_SERVICE_DIR/$project_name/hostname"
  manual_assert_file_exists "$TOR_SERVICE_DIR/$project_name/hostname" "true"

  # Make root owner of tor directory.
  sudo chown -R root "$TOR_SERVICE_DIR"
  sudo chmod 700 "$TOR_SERVICE_DIR/$project_name"

}

create_onion_domain_for_service() {
  local project_name="$1"
  local local_project_port="$2"
  local public_port_to_access_onion="$3"

  # TODO: include verify_apt_installedin project.
  verify_apt_installed "tor"

  kill_tor_if_already_running
  assert_tor_is_not_running

  ensure_onion_domain_is_created_by_starting_tor "$project_name" "$local_project_port" "$public_port_to_access_onion"

  # Assert the tor_log.txt does not contain error.
  assert_file_does_not_contains_string "\[err\]" "$TOR_LOG_FILEPATH"
}

ensure_onion_domain_is_created_by_starting_tor() {
  local project_name="$1"
  local local_project_port="$2"
  local public_port_to_access_onion="$3"

  local wait_time_sec=260

  local onion_domain
  #local max_tor_wait_time="$2"
  # TODO: include max_tor_wait_time as parameter
  yellow_msg "Now starting tor, and waiting (max) $wait_time_sec seconds to generate onion url locally."

  # Start "sudo tor" in the background
  sudo tor | tee "$TOR_LOG_FILEPATH" >/dev/null &
  # sudo tor & | tee "$TOR_LOG_FILEPATH" >/dev/null

  # Set the start time of the function
  start_time=$(date +%s)

  # Check if the onion URL exists in the hostname every 5 seconds, until 2 minutes have passed
  while true; do
    local onion_exists
    onion_exists=$(check_onion_url_exists_in_hostname "$project_name")

    # Check if the onion URL exists in the hostname
    if sudo test -f "$TOR_SERVICE_DIR/$project_name/hostname"; then
      if [[ "$onion_exists" == "FOUND" ]]; then

        onion_domain="$(get_onion_domain "$project_name")"

        # If the onion URL exists, terminate the "sudo tor" process and return 0
        kill_tor_if_already_running
        green_msg "Successfully created your onion domain locally. Proceeding.."
        sleep 5

        # TODO: verify the private key is valid for the onion domain.
        # TODO: verify whether it is reachable over tor.
        return 0
      fi
    fi

    sleep 1

    # Calculate the elapsed time from the start of the function
    elapsed_time=$(($(date +%s) - start_time))

    # If 2 minutes have passed, raise an exception and return 7
    if ((elapsed_time > wait_time_sec)); then
      kill_tor_if_already_running
      echo >&2 "Error: Onion URL:$onion_domain does not exist in hostname after $wait_time_sec seconds."
      exit 6
    fi

    # Wait for 5 seconds before checking again
    sleep 5
  done

}

kill_tor_if_already_running() {
  local output
  local normal_tor_closed
  local sudo_tor_closed
  while true; do
    output=$(netstat -ano | grep LISTEN | grep 9050)
    if [[ "$output" != "" ]]; then
      sudo killall tor
      sudo systemctl stop tor
      normal_tor_closed="false"
      sleep 2
    else
      normal_tor_closed="true"
    fi

    sudo_output=$(sudo netstat -ano | grep LISTEN | grep 9050)
    if [[ "$sudo_output" != "" ]]; then
      # sudo kill -9 `pidof tor`
      sudo killall tor
      sudo systemctl stop tor
      sleep 2
    else
      sudo_tor_closed="false"
      sudo_tor_closed="true"
    fi
    if [[ "$normal_tor_closed" == "true" ]] && [[ "$sudo_tor_closed" == "true" ]]; then
      return 0
    fi
  done
}

assert_tor_is_not_running() {
  local output
  output=$(netstat -ano | grep LISTEN | grep 9050)
  if [[ "$output" != "" ]]; then
    echo "ERROR, tor/something is still running on port 9050:$output"
    exit 6
  fi

}
