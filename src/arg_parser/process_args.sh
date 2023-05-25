#!/bin/bash

# Prepare Firefox version.
process_firefox_to_apt_flag() {
  local firefox_to_apt_flag="$1"

  if [ "$firefox_to_apt_flag" == "true" ]; then
    swap_snap_firefox_with_ppa_apt_firefox_installation
  fi
}

# TODO: call setup_services

process_get_onion_domain_flag() {
  local process_get_onion_domain="$1"
  local services="$2"

  if [ "$process_get_onion_domain" == "true" ]; then
    echo "" # Create newline
    nr_of_services=$(get_nr_of_services "$services")
    start=0
    for ((project_nr = start; project_nr < nr_of_services; project_nr++)); do
      local project_name
      local public_port_to_access_onion

      project_name="$(get_project_property_by_index "$services" "$project_nr" "project_name")"
      public_port_to_access_onion="$(get_project_property_by_index "$services" "$project_nr" "external_port")"

      # Override global verbosity setting to show onion domains.
      if [[ "$project_name" == "ssh" ]]; then
        local onion_domain
        onion_domain=$(get_onion_domain "$project_name")

        echo "You can ssh into this server with command:"
        green_msg "torsocks ssh $(whoami)@$onion_domain" "true"
      else
        local onion_address
        onion_address="$(get_onion_address "$project_name" "true" "$public_port_to_access_onion")"
        echo "Your onion domain for:$project_name, is:"
        green_msg "$onion_address" "true"
      fi
    done
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

process_get_file_from_server_into_client_flags() {
  local get_root_ca_certificate_into_client_flag="$1"
  process_get_server_gif_into_client_flag="$2"
  local server_username="$3"
  local server_onion_domain="$4"

  if [[ "$get_root_ca_certificate_into_client_flag" == "true" ]] || [[ "$process_get_server_gif_into_client_flag" == "true" ]]; then
    assert_is_non_empty_string "${server_username}"
    assert_is_non_empty_string "${server_onion_domain}"
    ssh_client_prerequisites

    # TODO: check has passwordless ssh access to server. If not, set it up.

    # TODO: assert has passwordless ssh access to server.
    if [ "$get_root_ca_certificate_into_client_flag" == "true" ]; then
      get_root_ca_into_client "$server_username" "$server_onion_domain"

    elif [ "$process_get_server_gif_into_client_flag" == "true" ]; then
      copy_files_from_server_into_client "$server_username" "$server_onion_domain" "/home/$server_username/server.gif" "$PWD/server.gif"
    fi
  fi
}

process_record_cli_flag() {
  local record_cli_flag="$1"
  local cli_record_filename="$2"
  if [ "$record_cli_flag" == "true" ]; then
    record_cli "$cli_record_filename"
  fi
}

process_add_root_ca_to_ubuntu_flag() {
  local add_root_ca_to_ubuntu_flag="$1"
  if [ "$add_root_ca_to_ubuntu_flag" == "true" ]; then
    assert_is_non_empty_string "$CA_PUBLIC_KEY_FILENAME"
    assert_is_non_empty_string "$CA_PUBLIC_CERT_FILENAME"
    install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"
  fi
}
