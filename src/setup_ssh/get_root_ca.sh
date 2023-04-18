#!/bin/bash

get_root_ca_into_client() {
  local server_username="$1"
  local server_onion_domain="$2"

  # Remove the local certificates directory (To prevent having a root ca that
  # does not match the self-signed certs from a previous run).
  sudo rm -r "certificates"
  manual_assert_dir_not_exists "certificates"
  create_ssl_cert_storage_directories
  create_root_certificate_directories

  copy_files_from_server_into_client "$server_username" "$server_onion_domain" "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME" "certificates/root/$CA_PUBLIC_CERT_FILENAME"
  manual_assert_file_exists "certificates/root/$CA_PUBLIC_CERT_FILENAME"

  #copy_file "certificates/root/$CA_PUBLIC_CERT_FILENAME" "$OUTPUT_PUBLIC_ROOT_CERT_FILEPATH" "true"

  # TODO: identify this device, if it is ubuntu, add it to trusted list.
  # TODO: If a phone argument is given, add it to phone.
  # TODO: If a Firefox apt argument is given, add it to apt Firefox.
  # TODO: If a Firefox snap argument is given, add it to snap Firefox.
  # TODO: If a brave argument is given bravely venture out, add it to brave browser.
  # TODO: If a tor argument is given add it to tor browser.

  # Add the server root ca to the trusted list on this client.
  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

}

copy_files_from_server_into_client() {
  local server_username="$1"
  local server_onion_domain="$2"
  local absolute_source_filepath="$3"
  local relative_target_filepath="$4"

  assert_is_non_empty_string "${absolute_source_filepath}"
  assert_is_non_empty_string "${relative_target_filepath}"

  # TODO: assert target dir exists.

  # If local target file exists, delete it.
  rm -f "$relative_target_filepath"

  # TODO: Assert no local root ca file exists.

  # Copy the root ca certificate from the server into this client.
  torsocks scp "$server_username@$server_onion_domain:$absolute_source_filepath" "$relative_target_filepath"

  # Assert local target file exists.
  manual_assert_file_exists "$relative_target_filepath"
}
