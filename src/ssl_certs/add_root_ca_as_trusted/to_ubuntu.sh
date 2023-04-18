#!/bin/bash
install_the_ca_cert_as_a_trusted_root_ca() {
  local ca_public_key_filename="$1"
  local ca_public_cert_filename="$2"

  if [ "$(file_exists "certificates/root/$ca_public_cert_filename")" == "NOTFOUND" ]; then
    # The file in the ca-certificates dir must be of extension .crt, so convert it into that (as a copy):
    manual_assert_file_exists "certificates/root/$ca_public_key_filename"
    openssl x509 -outform der -in "certificates/root/$ca_public_key_filename" -out "certificates/root/$ca_public_cert_filename" >>/dev/null 2>&1
  fi
  manual_assert_file_exists "certificates/root/$ca_public_cert_filename"

  # First remove any old cert if it pre-existed.
  sudo rm -f "$UBUNTU_CERTIFICATE_DIR$ca_public_cert_filename"
  sudo update-ca-certificates >>/dev/null 2>&1

  # On Debian & Derivatives:
  #- Move the CA certificate (`"$ca_private_key_filename"`) into `$UBUNTU_CERTIFICATE_DIRca.crt`.
  manual_assert_dir_exists "$UBUNTU_CERTIFICATE_DIR"
  sudo cp "certificates/root/$ca_public_cert_filename" "$UBUNTU_CERTIFICATE_DIR$ca_public_cert_filename"
  manual_assert_file_exists "$UBUNTU_CERTIFICATE_DIR$ca_public_cert_filename"

  # Update the Cert Store with:
  sudo update-ca-certificates >>/dev/null 2>&1

  # TODO: verify the root ca is added to the trusted list.
}
