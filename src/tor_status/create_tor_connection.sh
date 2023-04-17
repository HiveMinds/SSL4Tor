#!/bin/bash
start_tor_in_background() {
  local wait_time_sec=260

  sudo tor | tee "$TOR_LOG_FILEPATH" >/dev/null &
  start_time=$(date +%s)

  while true; do
    error_substring='\[err\]'
    if [ "$(file_contains_string "$error_substring" "$TOR_LOG_FILEPATH")" == "FOUND" ]; then
      kill_tor_if_already_running
      sleep 5
      sudo tor | tee "$TOR_LOG_FILEPATH" >/dev/null &
    else
      if [[ "$(tor_is_connected)" == "FOUND" ]]; then
        green_msg "Successfully setup tor connection."
        return 0
      else
        sleep 1
      fi
    fi
    sleep 1

    # Calculate the elapsed time from the start of the function
    elapsed_time=$(($(date +%s) - start_time))

    # If wait_time_sec seconds have passed, raise an exception and return 6.
    if ((elapsed_time > wait_time_sec)); then
      kill_tor_if_already_running
      echo >&2 "Error: a tor connection was not created after $wait_time_sec seconds."
      exit 6
    fi

    # Wait for 5 seconds before checking again.
    sleep 5
  done

}
