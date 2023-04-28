#!/bin/bash

manage_ssl_for_services() {
  local services="$1"

  install_apt_prerequisites

  # Create one onion domain per service.
  nr_of_services=$(get_nr_of_services "$services")
  start=0
  for ((project_nr = start; project_nr < nr_of_services; project_nr++)); do
    local local_project_port
    local project_name
    local public_port_to_access_onion

    # Get the project ports and names.
    local_project_port="$(get_project_property_by_index "$services" "$project_nr" "local_port")"
    project_name="$(get_project_property_by_index "$services" "$project_nr" "project_name")"
    public_port_to_access_onion="$(get_project_property_by_index "$services" "$project_nr" "external_port")"

    make_onion_domain_for_service "$local_project_port" "$project_name" "$public_port_to_access_onion"
    add_root_ca_certificates_to_server
    make_ssl_certs_for_service "$local_project_port" "$project_name" "$public_port_to_access_onion" "$ssl_password"
    apply_ssl_certs_to_service "$local_project_port"
  done
}

# Create onion domain(s).
make_onion_domain_for_service() {
  local local_project_port="$1"
  local project_name="$2"
  local public_port_to_access_onion="$3"

  install_apt_prerequisites

  # Create one onion domain per service.
  echo "Generating your onion domain for:$project_name"
  make_onion_domain "$project_name" "$local_project_port" "$public_port_to_access_onion"
  prepare_starting_tor "$project_name" "$local_project_port" "$public_port_to_access_onion"

  if [[ "$project_name" == "ssh" ]]; then
    ssh_server_prerequisites
  fi
}

# Create SSL certificates.
make_ssl_certs_for_service() {
  local local_project_port="$1"
  local project_name="$2"
  local public_port_to_access_onion="$3"
  local ssl_password="$4"

  assert_is_non_empty_string "${ssl_password}"
  make_root_ssl_certs "$ssl_password"

  local onion_domain
  onion_domain="$(get_onion_domain "$project_name")"
  assert_is_non_empty_string "${onion_domain}"
  make_project_ssl_certs "$onion_domain" "$project_name"

  # Don't kill the ssh service at port 22 that may already be running.
  if [ "$project_name" == "dash" ]; then
    run_dash_in_background "$local_project_port" "$project_name" &
    green_msg "Dash is running in the background for: $project_name at port:$local_project_port. Proceeding."

    # This is only done if the project name is dash.
    # TODO: verify it for all supported projects.
    kill_tor_if_already_running
    verify_onion_address_is_reachable "$project_name" "$public_port_to_access_onion" "true"
  fi
  rm "$TEMP_SSL_PWD_FILENAME"

}

apply_ssl_certs_to_service() {
  local project_name="$1"

  if [[ "$project_name" == "gitlab" ]]; then
    local onion_domain
    onion_domain="$(get_onion_domain "$project_name")"
    assert_is_non_empty_string "${onion_domain}"

    # TODO: also support onion urls.
    add_private_and_public_ssl_certs_to_gitlab "$project_name" "localhost" "$SSL_PRIVATE_KEY_FILENAME" "$SSL_PUBLIC_KEY_FILENAME"
  fi
}
