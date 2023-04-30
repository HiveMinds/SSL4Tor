#!/bin/bash

copy_file() {
  input_path="$1"
  output_path="$2"
  use_sudo="$3"
  manual_assert_file_exists "$input_path"

  if [ "$use_sudo" == "true" ]; then
    sudo cp "$input_path" "$output_path"
  else
    cp "$input_path" "$output_path"
  fi

  manual_assert_file_exists "$output_path"
}

md5sum_is_identical() {
  local left_filepath="$1"
  local right_filepath="$2"

  local md5sum1
  md5sum1=$(md5sum "$left_filepath" | awk '{print $1}')
  local md5sum2
  md5sum2=$(md5sum "$right_filepath" | awk '{print $1}')

  if [ "$md5sum1" != "$md5sum2" ]; then
    echo "NOTFOUND"
  else
    echo "FOUND"
  fi
}

assert_md5sum_identical() {
  local left_filepath="$1"
  local right_filepath="$2"
  if [[ "$(md5sum_is_identical "$left_filepath" "$right_filepath")" != "FOUND" ]]; then
    echo "Error, root ca certificate was not added to apt Firefox."
    exit 6
  fi
}
