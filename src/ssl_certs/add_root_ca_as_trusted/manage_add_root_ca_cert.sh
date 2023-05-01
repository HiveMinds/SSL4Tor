#!/bin/bash

add_root_ca_certificates_to_server() {
  assert_ssl_certs_for_root_ca_exist

  # Add root ca to Ubuntu.
  # TODO: write check to see if root ca is already added to Ubuntu. If not, add it.
  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

  # Assert the root project for this run/these services is created.
  manual_assert_file_exists "certificates/root/$CA_PUBLIC_CERT_FILENAME"
  # Assert the root ca is in the place Ubuntu (and Firefox) expect it to be.
  manual_assert_file_exists "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"
  # Assert the root ca hash is as expected.
  assert_md5sum_identical "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME" "certificates/root/$CA_PUBLIC_CERT_FILENAME"

  # Add root ca to apt or snap Firefox.
  if [[ "$(firefox_is_installed)" == "FOUND" ]]; then
    if [[ "$(has_added_self_signed_root_ca_cert_to_firefox)" == "NOTFOUND" ]]; then
      read -p "ADDING"
      add_self_signed_root_cert_to_firefox
      close_restart_close_firefox
    fi
    read -p "DONE ADDING"
    assert_has_added_self_signed_root_ca_cert_to_firefox
  fi

  # TODO: add root ca to Brave.

  # TODO: add root ca to Tor browser.
}
