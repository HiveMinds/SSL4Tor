#!/bin/bash

add_root_ca_certificates_to_server() {
  assert_ssl_certs_for_root_ca_exist

  # Add root ca to Ubuntu.
  # TODO: write check to see if root ca is already added to Ubuntu. If not, add it.
  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

  # Add root ca to apt Firefox.
  if [[ "$(has_added_self_signed_root_ca_cert_to_apt_firefox)" == "NOTFOUND" ]]; then
    add_self_signed_root_cert_to_firefox
  fi
  assert_has_added_self_signed_root_ca_cert_to_apt_firefox

  # TODO: add root ca to snap Firefox.

  # TODO: add root ca to Brave.

  # TODO: add root ca to Tor browser.
}
