#!/bin/bash

verify_onion_address_is_reachable() {
  local project_name="$1"
  local public_port_to_access_onion="$2"
  local use_https="$3"

  local wait_time_sec=260

  local onion_exists
  onion_exists=$(check_onion_url_exists_in_hostname "$project_name")
  if [[ "$onion_exists" == "FOUND" ]]; then
    local onion_address
    onion_address="$(get_onion_address "$project_name" "$use_https" "$public_port_to_access_onion")"

    echo "Now starting tor, and waiting (max) $wait_time_sec seconds to "
    echo "    determine whether your tor website is reachable at: $onion_address"

    # Start "sudo tor" in the background
    sudo tor | tee "$TOR_LOG_FILEPATH" >/dev/null &

    # Set the start time of the function
    start_time=$(date +%s)
    while true; do
      if [ "$(onion_address_is_available "$onion_address")" == "FOUND" ]; then
        printf 'Was able to connect to:%s\n\n' "$onion_address"
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
