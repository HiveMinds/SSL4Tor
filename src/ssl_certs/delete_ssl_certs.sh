#!/bin/bash

delete_projects_ssl_certs() {
  sudo rm -f -r "certificates/ssl_cert"
  sudo rm -f -r "certificates/merged"
}

delete_root_ca_certs() {
  sudo rm -f -r "certificates/root"
  # First remove any old cert if it pre-existed.
  sudo rm -f "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"
  sudo update-ca-certificates >>/dev/null 2>&1
}
