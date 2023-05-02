#!/bin/bash

verify_service_is_reachable_on_onion() {
  local local_project_port="$1"
  local project_name="$2"
  local public_port_to_access_onion="$3"

  ensure_https_services_run_locally "$local_project_port" "$project_name"

  # TODO: include support for GitLab onion.
  #if [[ "$project_name" != "gitlab" ]] && [[ "$project_name" != "ssh" ]]; then
  if [[ "$project_name" != "ssh" ]]; then
    kill_tor_if_already_running
    verify_onion_address_is_reachable "$project_name" "$public_port_to_access_onion"
  elif [[ "$project_name" == "ssh" ]]; then
    verify_ssh_onion_domain_is_reachable "$public_port_to_access_onion"
  fi
}

ensure_https_services_run_locally() {
  local local_project_port="$1"
  local project_name="$2"

  # Don't kill the ssh service at port 22 that may already be running.
  if [ "$project_name" == "dash" ]; then
    run_dash_in_background "$local_project_port" "$project_name" &
    green_msg "Dash is running in the background for: $project_name at port:$local_project_port. Proceeding."

  elif [[ "$project_name" == "ssh" ]]; then
    ssh_server_prerequisites
  fi
}

verify_onion_address_is_reachable() {
  local project_name="$1"
  local public_port_to_access_onion="$2"

  local wait_time_sec=260

  local onion_exists
  onion_exists=$(check_onion_url_exists_in_hostname "$project_name")
  if [[ "$onion_exists" == "FOUND" ]]; then
    local use_https="true"
    local onion_address
    onion_address="$(get_onion_address "$project_name" "$use_https" "$public_port_to_access_onion")"

    yellow_msg "Now starting tor, and waiting (max) $wait_time_sec seconds to determine whether your tor website is reachable at:"

    # Start "sudo tor" in the background
    sudo tor | tee "$TOR_LOG_FILEPATH" >/dev/null &

    # Set the start time of the function
    start_time=$(date +%s)
    while true; do
      # TODO: include check to see if $TOR_LOG_FILEPATH contains:[err]
      if [ "$(onion_address_is_available "$onion_address")" == "FOUND" ]; then
        green_msg "SSL certificate for:$onion_address is valid! Verified by connecting to that onion."

        return 0
      fi

      sleep 1

      # Calculate the elapsed time from the start of the function
      elapsed_time=$(($(date +%s) - start_time))

      # If 2 minutes have passed, raise an exception and return 7
      if ((elapsed_time > wait_time_sec)); then
        kill_tor_if_already_running
        echo >&2 "Error: $onion_address is not reachable after $wait_time_sec seconds."
        exit 6
      fi
      sleep 5 # Wait 5 seconds before checking again.
    done
  else
    echo "Error, did not find onion url in hostname file for tor in:"
    echo "$TOR_SERVICE_DIR/$project_name/hostname"
    exit 5
  fi
}

verify_ssh_onion_domain_is_reachable() {
  local public_port_to_access_onion="$1"

  local wait_time_sec=260

  local onion_exists
  onion_exists=$(check_onion_url_exists_in_hostname "ssh")
  if [[ "$onion_exists" == "FOUND" ]]; then
    local onion_domain
    onion_domain=$(get_onion_domain "ssh")

    yellow_msg "Now starting tor, and waiting (max) $wait_time_sec seconds to determine whether your ssh website is reachable at:"
    yellow_msg "$onion_domain"

    # Start "sudo tor" in the background
    sudo tor | tee "$TOR_LOG_FILEPATH" >/dev/null &

    # Set the start time of the function
    start_time=$(date +%s)
    while true; do

      # TODO: include check to see if $TOR_LOG_FILEPATH contains:[err]
      if [ "$(ssh_onion_is_available "$onion_domain" "$public_port_to_access_onion")" == "FOUND" ]; then
        echo "Verified you can ssh into this server with command:"
        green_msg "torsocks ssh $(whoami)@$onion_domain" "true"
        return 0
      fi

      sleep 1

      # Calculate the elapsed time from the start of the function
      elapsed_time=$(($(date +%s) - start_time))

      # If 2 minutes have passed, raise an exception and return 7
      if ((elapsed_time > wait_time_sec)); then
        kill_tor_if_already_running
        echo >&2 "Error: $onion_address is not reachable after $wait_time_sec seconds."
        exit 6
      fi
      sleep 5 # Wait 5 seconds before checking again.
    done
  else
    echo "Error, did not find onion url in hostname file for tor in:"
    echo "$TOR_SERVICE_DIR/ssh/hostname"
    exit 5
  fi
}
