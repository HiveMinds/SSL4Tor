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

# Prepare Firefox version.
process_firefox_to_apt_flag() {
  local firefox_to_apt_flag="$1"

  if [ "$firefox_to_apt_flag" == "true" ]; then
    swap_snap_firefox_with_ppa_apt_firefox_installation
  fi
}

# Create onion domain(s).
process_make_onion_domain_flag() {
  local make_onion_domain_flag="$1"
  local one_domain_per_service_flag="$2"
  local services="$3"

  if [ "$make_onion_domain_flag" == "true" ]; then
    install_apt_prerequisites

    if [ "$one_domain_per_service_flag" == "true" ]; then
      nr_of_services=$(get_nr_of_services "$services")
      start=0
      for ((project_nr = start; project_nr < nr_of_services; project_nr++)); do
        local local_project_port
        local project_name
        local public_port_to_access_onion

        local_project_port="$(get_project_property_by_index "$services" "$project_nr" "local_port")"
        project_name="$(get_project_property_by_index "$services" "$project_nr" "project_name")"
        public_port_to_access_onion="$(get_project_property_by_index "$services" "$project_nr" "external_port")"

        echo "Generating your onion domain for:$project_name"
        make_onion_domain "$one_domain_per_service_flag" "$project_name" "$local_project_port" "$public_port_to_access_onion"
        prepare_starting_tor "$project_name" "$local_project_port" "$public_port_to_access_onion"

        if [[ "$project_name" == "ssh" ]]; then
          ssh_server_prerequisites
        fi
      done
    fi
  fi
}

process_get_onion_domain_flag() {
  local process_get_onion_domain="$1"
  local services="$2"

  if [ "$process_get_onion_domain" == "true" ]; then
    echo "" # Create newline
    nr_of_services=$(get_nr_of_services "$services")
    start=0
    for ((project_nr = start; project_nr < nr_of_services; project_nr++)); do
      local project_name
      project_name="$(get_project_property_by_index "$services" "$project_nr" "project_name")"

      local onion_domain
      onion_domain=$(get_onion_domain "$project_name")

      # Override global verbosity setting to show onion domains.
      if [[ "$project_name" == "ssh" ]]; then
        echo "You can ssh into this server with command:"
        green_msg "torsocks ssh $(whoami)@$onion_domain" "true"
      else
        echo "Your onion domain for:$project_name, is:"
        green_msg "$onion_domain" "true"
      fi
    done
  fi
}

# Create SSL certificates.
process_make_project_ssl_certs_flag() {
  local make_project_ssl_certs_flag="$1"
  local one_domain_per_service_flag="$2"
  local background_dash_flag="$3"
  local services="$4"
  local ssl_password="$5"

  if [ "$make_project_ssl_certs_flag" == "true" ]; then

    assert_is_non_empty_string "${ssl_password}"
    make_root_ssl_certs "$ssl_password"

    if [ "$one_domain_per_service_flag" == "true" ]; then
      nr_of_services=$(get_nr_of_services "$services")
      start=0
      for ((project_nr = start; project_nr < nr_of_services; project_nr++)); do
        local local_project_port
        local project_name
        local public_port_to_access_onion

        local_project_port="$(get_project_property_by_index "$services" "$project_nr" "local_port")"
        project_name="$(get_project_property_by_index "$services" "$project_nr" "project_name")"
        public_port_to_access_onion="$(get_project_property_by_index "$services" "$project_nr" "external_port")"

        local onion_domain
        onion_domain="$(get_onion_domain "$project_name")"
        assert_is_non_empty_string "${onion_domain}"
        make_project_ssl_certs "$onion_domain" "$project_name"

        # Don't kill the ssh service at port 22 that may already be running.
        if [ "$project_name" != "ssh" ]; then
          if [ "$background_dash_flag" == "true" ]; then
            run_dash_in_background "$local_project_port" "$project_name" &
            green_msg "Dash is running in the background for: $project_name at port:$local_project_port. Proceeding."
          fi
          kill_tor_if_already_running
          verify_onion_address_is_reachable "$project_name" "$public_port_to_access_onion" "true"
        fi
      done
      rm "$TEMP_SSL_PWD_FILENAME"
    fi
  fi
}

process_apply_certs_to_project_flag() {
  local apply_certs_to_project_flag="$1"

  if [ "$apply_certs_to_project_flag" == "true" ]; then
    echo "TODO: applying certs"
  fi
}

# Verify https access to onion domain.
process_check_https_flag() {
  local check_https_flag="$1"

  if [ "$check_https_flag" == "true" ]; then
    echo "TODO: (allow direct) Checking your tor domain is available over https."
  fi
}

# Add self-signed ssl certificate to (apt) Firefox.
process_add_ssl_root_cert_to_apt_firefox_flag() {
  local add_ssl_root_cert_to_apt_firefox_flag="$1"
  local project_name="$2"

  if [ "$add_ssl_root_cert_to_apt_firefox_flag" == "true" ]; then
    echo "Adding your SSL certificates to firefox."

    assert_is_non_empty_string "${project_name}"
    add_self_signed_root_cert_to_firefox "$project_name"
  fi
}

process_setup_ssh_server_flag() {
  local setup_ssh_server_flag="$1"

  if [ "$setup_ssh_server_flag" == "true" ]; then
    ssh_server_prerequisites
  fi
}

process_setup_ssh_client_flag() {
  local setup_ssh_client_flag="$1"
  local server_username="$2"
  local server_onion_domain="$3"

  if [ "$setup_ssh_client_flag" == "true" ]; then
    ssh_client_prerequisites
    setup_passwordless_ssh_access_to_server "$server_username" "$server_onion_domain"
  fi
}

process_get_root_ca_certificate_flag() {
  local get_root_ca_certificate_flag="$1"
  local server_username="$2"
  local server_onion_domain="$3"

  if [ "$get_root_ca_certificate_flag" == "true" ]; then
    assert_is_non_empty_string "${server_username}"
    assert_is_non_empty_string "${server_onion_domain}"
    ssh_client_prerequisites

    # TODO: check has passwordless ssh access to server. If not, set it up.

    # TODO: assert has passwordless ssh access to server.
    copy_public_root_ca_certificate_into_this_device "$server_username" "$server_onion_domain"
  fi
}

process_record_cli_flag() {
  local record_cli_flag="$1"
  local cli_record_filename="$2"
  if [ "$record_cli_flag" == "true" ]; then
    record_cli "$cli_record_filename"
  fi
}
