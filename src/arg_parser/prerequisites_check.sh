#!/bin/bash

check_prerequisites() {
  local services="$1"

  # Ensure ports are populated and valid, and that project names are valid.
  assert_services_are_valid "$services"
  assert_services_are_supported "$services"

  # Check whether the desired files already exist.

  # Check whether the desired SSL certificates are already added to Ubuntu
  # and browsers.

  # Check whether the desired services are already running.

  # Check whether the desired SSL certificates are already added to desired
  # services.
}

check_if_desired_files_already_exist() {
  # Check if the onion domain for this service already exists.

  # Check if the SSL certificate already exists for this service.

  # Check if the root ca certificate already exists.

  echo "TODO"
}

check_if_services_are_running() {
  echo "TODO"
}

check_if_root_ca_cert_is_added_to_targets() {

  # Check if root ca cert is added to Ubuntu.
  # Check if root ca cert is added to apt Firefox.
  # Check if root ca cert is added to snap Firefox.
  # Check if root ca cert is added to brave.
  # Check if root ca cert is added to tor.
  echo "TODO"
}

check_if_ssl_certs_are_added_to_services() {

  # Check if root ca cert is added to Ubuntu.
  # Check if root ca cert is added to apt Firefox.
  # Check if root ca cert is added to snap Firefox.
  # Check if root ca cert is added to brave.
  # Check if root ca cert is added to tor.
  echo "TODO"
}
