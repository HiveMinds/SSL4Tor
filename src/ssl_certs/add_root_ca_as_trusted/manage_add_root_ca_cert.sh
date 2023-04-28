#!/bin/bash

add_root_ca_certificates_to_server() {
  assert_ssl_certs_for_root_ca_exist

  # Add root ca to Ubuntu.
  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

  # Add root ca to apt Firefox.
  add_self_signed_root_cert_to_firefox

  # TODO: add root ca to snap Firefox.

  # TODO: add root ca to Brave.

  # TODO: add root ca to Tor browser.
}
