#!/bin/bash

# Works
command_output_contains() {
  local substring="$1"
  shift
  # shellcheck disable=SC2124 # TODO: remove need for this shellcheck disable.
  local command_output="$@"
  if grep -q "$substring" <<<"$command_output"; then
    #if "$command" | grep -q "$substring"; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}
