#!/bin/bash

copy_public_root_ca_certificate_into_this_device() {
  local server_username="$1"
  local server_onion_domain="$2"

  # TODO: If local root ca file exists, delete it.

  # TODO: Assert no local root ca file exists.

  # Copy the root ca certificate from the server into this client.
  torsocks scp "$server_username@$server_onion_domain:/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME" "$PWD/"

  # TODO: Assert local root ca file exists.
  manual_assert_file_exists "$PWD/$CA_PUBLIC_CERT_FILENAME"
}

copy_files_from_server_into_client() {
  local server_username="$1"
  local server_onion_domain="$2"
  local absolute_source_filepath="$3"
  local absolute_target_filepath="$4"

  assert_is_non_empty_string "${absolute_source_filepath}"
  assert_is_non_empty_string "${absolute_target_filepath}"

  # TODO: assert target dir exists.

  # If local target file exists, delete it.
  rm -f "$absolute_target_filepath"

  # TODO: Assert no local root ca file exists.

  # Copy the root ca certificate from the server into this client.
  torsocks scp "$server_username@$server_onion_domain:$absolute_source_filepath" "$absolute_target_filepath"

  # Assert local target file exists.
  manual_assert_file_exists "$absolute_target_filepath"
}
