#!/bin/bash

# Returns FOUND if any of the SSL certificate files for this project exist.
ssl_certs_for_project_exist() {
  local project_name="$1"

  if test -f "certificates/ssl_cert/$project_name/$SSL_PRIVATE_KEY_FILENAME"; then
    echo "FOUND"
    return 0
  elif test -f "certificates/ssl_cert/$project_name/sign_request/$CA_SIGN_SSL_CERT_REQUEST_FILENAME"; then
    echo "FOUND"
    return 0
  elif test -f "certificates/ssl_cert/$project_name/sign_request/$SIGNED_DOMAINS_FILENAME"; then
    echo "FOUND"
    return 0
  elif test -f "certificates/ssl_cert/$project_name/$SSL_PUBLIC_KEY_FILENAME"; then
    echo "FOUND"
    return 0
  elif test -f "certificates/merged/$project_name/$MERGED_CA_SSL_CERT_FILENAME"; then
    echo "FOUND"
    return 0
  else
    echo "NOTFOUND"
    return 0
  fi
}

# Returns FOUND if any of the root ca SSL certificate files exist.
any_ssl_certs_for_root_ca_exist() {
  if test -f "certificates/root/$CA_PRIVATE_KEY_FILENAME"; then
    echo "FOUND"
    return 0
  elif test -f "certificates/root/$CA_PUBLIC_CERT_FILENAME"; then
    echo "FOUND"
    return 0
  elif test -f "certificates/root/$CA_PUBLIC_KEY_FILENAME"; then
    echo "FOUND"
    return 0
  elif test -f "$OUTPUT_PUBLIC_ROOT_CERT_FILEPATH"; then
    echo "FOUND"
    return 0
  elif test -f "$TEMP_SSL_PWD_FILENAME"; then
    echo "FOUND"
    return 0
  elif sudo test ! -f "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_KEY_FILENAME"; then
    echo "FOUND"
    return 0
  elif sudo test ! -f "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"; then
    echo "FOUND"
    return 0
  else
    echo "NOTFOUND"
  fi
}

assert_any_ssl_certs_for_root_ca_exist() {
  if [[ "$(any_ssl_certs_for_root_ca_exist)" != "FOUND" ]]; then
    echo "Error root ca certificate not found."
    exit 6
  fi
}
