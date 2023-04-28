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

    add_service_to_torrc_for_service "$local_project_port" "$project_name" "$public_port_to_access_onion"
    add_root_ca_certificates_to_server
    make_ssl_certs_for_service "$project_name" "$ssl_password"
    apply_ssl_certs_to_service "$local_project_port"
    verify_service_is_reachable_on_onion "$local_project_port" "$project_name" "$public_port_to_access_onion"
  done
}

# Create onion domain(s).
add_service_to_torrc_for_service() {
  local local_project_port="$1"
  local project_name="$2"
  local public_port_to_access_onion="$3"

  # Create one onion domain per service.
  echo "Generating your onion domain for:$project_name"
  add_service_to_torrc "$project_name" "$local_project_port" "$public_port_to_access_onion"
  create_onion_domain_for_service "$project_name" "$local_project_port" "$public_port_to_access_onion"
}

# Create SSL certificates.
make_ssl_certs_for_service() {
  local project_name="$1"
  local ssl_password="$2"

  assert_is_non_empty_string "${ssl_password}"
  make_root_ssl_certs "$ssl_password"

  local onion_domain
  onion_domain="$(get_onion_domain "$project_name")"
  assert_is_non_empty_string "${onion_domain}"
  make_project_ssl_certs "$onion_domain" "$project_name"
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
