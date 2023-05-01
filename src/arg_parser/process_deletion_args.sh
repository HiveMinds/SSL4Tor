#!/bin/bash

# Delete files from previous run.
process_delete_onion_domains_flag() {
  local delete_onion_domain_flag="$1"

  if [ "$delete_onion_domain_flag" == "true" ]; then
    delete_onion_domain
  fi
}

process_delete_ssl_cert_flags() {
  local delete_projects_ssl_certs_flag="$1"
  local delete_root_ca_certs_flag="$2"

  if [ "$delete_projects_ssl_certs_flag" == "true" ]; then
    delete_projects_ssl_certs
  fi
  if [ "$delete_root_ca_certs_flag" == "true" ]; then
    delete_root_ca_certs
  fi
}
