#!/bin/bash

# Returns FOUND if gitlab is running, NOTFOUND otherwise.
# TODO: be specific on which address and port GitLab should be running.
gitlab_runs_on_http() {
  #local use_https="$1"
  #local domain_name="$2"
  #local port_nr="$3"

  local curl_output
  curl_output=$(curl http://localhost:80)
  local expected_curl_output='<html><body>You are being <a href="http://localhost/users/sign_in">redirected</a>.</body></html>'
  if [[ "$curl_output" != "$expected_curl_output" ]]; then
    echo "NOTFOUND"
  elif [[ "$curl_output" == "$expected_curl_output" ]]; then
    echo "FOUND"
  else
    echo "Unexpected state."
    exit 6
  fi
}

assert_gitlab_runs() {
  # TODO: include check for https
  if [[ "$(gitlab_runs_on_http)" != "FOUND" ]]; then
    echo "Error, GitLab was not found running on http."
    exit 5
  fi
}
