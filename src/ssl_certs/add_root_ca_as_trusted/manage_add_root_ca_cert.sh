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
  # TODO: support adding root ca to snap Firefox.
  if [[ "$(firefox_is_installed)" == "FOUND" ]]; then
    local policies_filepath
    policies_filepath=$(get_firefox_policies_path)
    if [[ "$(has_added_self_signed_root_ca_cert_to_browser "$policies_filepath")" == "NOTFOUND" ]]; then
      add_self_signed_root_cert_to_browser "$policies_filepath" "firefox"
      close_restart_close_browser "firefox"
    fi
    assert_has_added_self_signed_root_ca_cert_to_browser "$policies_filepath"
  fi

  # Add root ca to Brave.
  if [[ "$(snap_package_is_installed "brave")" == "NOTFOUND" ]]; then
    ensure_snap_pkg "brave"
  fi

  if [[ "$(snap_package_is_installed "brave")" == "FOUND" ]]; then
    local policies_filepath
    policies_filepath=$(get_brave_policies_path)
    if [[ "$(has_added_self_signed_root_ca_cert_to_browser "$policies_filepath")" == "NOTFOUND" ]]; then
      add_self_signed_root_cert_to_browser "$policies_filepath" "brave"
      close_restart_close_browser "brave"
    fi
    assert_has_added_self_signed_root_ca_cert_to_browser "$policies_filepath"
  fi

  # TODO: add root ca to Tor browser.
}
