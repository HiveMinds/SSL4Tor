#!/bin/bash

delete_projects_ssl_certs() {
  sudo rm -r "certificates/ssl_cert"
  sudo rm -r "certificates/merged"
}

delete_root_ca_certs() {
  sudo rm -r "certificates/root"
}
