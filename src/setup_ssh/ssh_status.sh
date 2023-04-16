#!/bin/bash
# source src/helper_parsing.sh && source src/setup_ssh/ssh_status.sh && can_find_ssh_service
can_find_ssh_service() {
  local output_that_also_captures_error
  output_that_also_captures_error=$(sudo systemctl status ssh 2>&1)

  local expected_if_found_1="Loaded: "
  local expected_if_found_2="Active: "

  if [[ "$output_that_also_captures_error" == "Unit ssh.service could not be found."* ]]; then
    echo "NOTFOUND"
  elif [[ "$(command_output_contains "$expected_if_found_1" "$output_that_also_captures_error")" == "FOUND" ]]; then
    if [[ "$(command_output_contains "$expected_if_found_2" "$output_that_also_captures_error")" == "FOUND" ]]; then
      echo "FOUND"
    else
      echo "Error, partial unexpected output on ssh status check:$output_that_also_captures_error."
      exit 6
    fi
  elif [[ "$output_that_also_captures_error" != "" ]]; then
    echo "Error, complete unexpected output on ssh status check:$output_that_also_captures_error."
    exit 6
  else
    echo "Error, empty output on ssh status check:$output_that_also_captures_error."
    exit 6
  fi
}

# source src/helper_parsing.sh && source src/setup_ssh/ssh_status.sh && safely_check_ssh_service_is_enabled
safely_check_ssh_service_is_enabled() {
  local output_that_also_captures_error
  output_that_also_captures_error=$(sudo systemctl status ssh 2>&1)

  local expected_enabled="Loaded: loaded (/lib/systemd/system/ssh.service; enabled;"
  local expected_disabled="Loaded: loaded (/lib/systemd/system/ssh.service; disabled;"

  if [[ "$(can_find_ssh_service)" == "FOUND" ]]; then
    if [[ "$(command_output_contains "$expected_enabled" "$output_that_also_captures_error")" == "FOUND" ]]; then
      echo "FOUND"
    elif [[ "$(command_output_contains "$expected_disabled" "$output_that_also_captures_error")" == "FOUND" ]]; then
      echo "NOTFOUND"
    else
      echo "Did not find expected substrings:$output_that_also_captures_error"
      exit 6
    fi
  else
    echo "NOTFOUND"
  fi
}

# source src/helper_parsing.sh && source src/setup_ssh/ssh_status.sh && safely_check_ssh_service_is_active
safely_check_ssh_service_is_active() {
  local output_that_also_captures_error
  output_that_also_captures_error=$(sudo systemctl status ssh 2>&1)

  local expected_if_not_active="Active: inactive (dead) "
  local expected_if_active="Active: active (running)"

  if [[ "$(can_find_ssh_service)" == "FOUND" ]]; then
    if [[ "$(safely_check_ssh_service_is_enabled)" == "FOUND" ]]; then
      if [[ "$(command_output_contains "$expected_if_not_active" "$output_that_also_captures_error")" == "FOUND" ]]; then
        echo "NOTFOUND"
      elif [[ "$(command_output_contains "$expected_if_active" "$output_that_also_captures_error")" == "FOUND" ]]; then
        echo "FOUND"
      else
        echo "Error, partial unexpected output on ssh status check:$output_that_also_captures_error."
        exit 6
      fi
    else
      echo "NOTFOUND"
    fi
  else
    echo "NOTFOUND"
  fi
}

assert_ssh_service_is_available_enabled_and_active() {
  if [[ "$(safely_check_ssh_service_is_active)" != "FOUND" ]]; then
    echo "Error, ssh status was not found to be running."
    exit 6
  fi
}

assert_ssh_service_is_not_available_enabled_and_active() {
  if [[ "$(safely_check_ssh_service_is_active)" != "NOTFOUND" ]]; then
    echo "Error, ssh status was found to be running."
    exit 6
  fi
}
