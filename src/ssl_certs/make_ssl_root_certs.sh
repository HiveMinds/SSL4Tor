#!/bin/bash

# shellcheck disable=SC2153

make_root_ssl_certs() {
  local ssl_password="$1"

  # TODO: if files already exist, perform double check on whether user wants to
  # overwrite the files.

  delete_root_certificate
  create_root_certificate_directories

  # Generate and apply certificate.
  generate_root_ca_cert "$CA_PRIVATE_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$ssl_password"

  # Add the server root ca to the trusted list on this server.
  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"
  manual_assert_file_exists "certificates/root/$CA_PUBLIC_CERT_FILENAME"

  copy_file "certificates/root/$CA_PUBLIC_CERT_FILENAME" "$OUTPUT_PUBLIC_ROOT_CERT_FILEPATH" "true"
}

delete_root_certificate() {
  rm -f "certificates/root/$CA_PRIVATE_KEY_FILENAME"
  rm -f "certificates/root/$CA_PUBLIC_CERT_FILENAME"
  rm -f "certificates/root/$CA_PUBLIC_KEY_FILENAME"

  sudo rm -f "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_KEY_FILENAME"
  sudo rm -f "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"
  sudo rm -r "$UBUNTU_CERTIFICATE_DIR"

  rm -f "$OUTPUT_PUBLIC_ROOT_CERT_FILEPATH"

  # TODO: put the pwd file outside of the repo.
  # TODO: pass pwd through commandline instead of via file.
  rm -f "$TEMP_SSL_PWD_FILENAME"
}

create_root_certificate_directories() {
  mkdir -p "certificates/root/"
  sudo mkdir -p "$UBUNTU_CERTIFICATE_DIR"

}

generate_root_ca_cert() {
  local ca_private_key_filename="$1"
  local ca_public_key_filename="$2"
  local ssl_password="$3"

  echo "$ssl_password" >"$TEMP_SSL_PWD_FILENAME"

  # Generate RSA
  openssl genrsa -passout file:"$TEMP_SSL_PWD_FILENAME" -aes256 -out "certificates/root/$ca_private_key_filename" 4096 >>/dev/null 2>&1

  # Generate a public CA Cert
  openssl req -passin file:"$TEMP_SSL_PWD_FILENAME" -subj "/C=$COUNTRY_CODE/" -new -x509 -sha256 -days 365 -key "certificates/root/$ca_private_key_filename" -out "certificates/root/$ca_public_key_filename" >>/dev/null 2>&1

  manual_assert_file_exists "certificates/root/$ca_public_key_filename"
}
