#!/bin/bash

delete_projects_ssl_certs() {
  sudo rm -f -r "certificates/ssl_cert"
  sudo rm -f -r "certificates/merged"
}

delete_root_ca_certs() {
  sudo rm -f -r "certificates/root"
  sudo rm -f "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"
}
