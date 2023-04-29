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

assert_md5sum_identical() {
  local left_filepath="$1"
  local right_filepath="$2"

  local md5sum1
  md5sum1=$(md5sum "$left_filepath" | awk '{print $1}')
  local md5sum2
  md5sum2=$(md5sum "$right_filepath" | awk '{print $1}')

  if [ "$md5sum1" != "$md5sum2" ]; then
    echo "Error: MD5 checksums of $left_filepath and $right_filepath are not identical"
    exit 1
  fi
}
