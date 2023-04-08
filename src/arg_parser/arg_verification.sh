#!/bin/bash

assert_is_non_empty_string() {
  local string="$1"
  if [ "${string}" == "" ]; then
    echo "Error, the incoming string was empty."
    exit 70
  fi
}
