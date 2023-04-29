#!/bin/bash

# Delete files from previous run.
process_delete_onion_domain_flag() {
  local delete_onion_domain_flag="$1"

  if [ "$delete_onion_domain_flag" == "true" ]; then
    delete_onion_domain "$project_name"
  fi
}

process_delete_projects_ssl_certs_flag() {
  local delete_projects_ssl_certs_flag="$1"
  local project_name="$2"

  if [ "$delete_projects_ssl_certs_flag" == "true" ]; then
    echo "Deleting your self-signed project SSL certificates. Root CA is preserved."
    delete_projects_ssl_certs
  fi
}
