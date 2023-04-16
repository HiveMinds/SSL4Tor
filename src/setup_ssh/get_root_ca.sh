#!/bin/bash

copy_public_root_ca_certificate_into_this_device() {
  local server_username="$1"
  local server_onion_domain="$2"

  # TODO: If local root ca file exists, delete it.

  # TODO: Assert no local root ca file exists.

  # Copy the root ca certificate from the server into this client.
  torsocks scp "$server_username@$server_onion_domain:/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME" "$PWD/../"

  # TODO: Assert local root ca file exists.
}
