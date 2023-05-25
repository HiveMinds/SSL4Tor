#!/bin/bash
parse_args() {
  # The incoming function arguments are the cli arguments.

  # Specify default argument values.
  local add_root_ca_to_ubuntu_flag='false'
  local delete_onion_domain_flag='false'
  local delete_projects_ssl_certs_flag='false'
  local delete_root_ca_certs_flag='false'
  local firefox_to_apt_flag='false'
  local get_onion_domain_flag='false'
  local get_root_ca_certificate_into_client_flag='false'
  local get_server_gif_into_client_flag='false'
  local record_cli_flag='false'
  local setup_ssh_client_flag='false'

  # $# gives the length/number of the incoming function arguments.
  # the shift command eats the first element of that array, making it shorter.
  while [[ $# -gt 0 ]]; do
    case $1 in
      -aru | --add-root-ca-to-ubuntu)
        add_root_ca_to_ubuntu_flag='true'
        shift # past argument
        ;;
      -do | --delete-onion-domain)
        delete_onion_domain_flag='true'
        shift # past argument
        ;;
      -dpc | --delete-projects-ssl-certs)
        delete_projects_ssl_certs_flag='true'
        shift # past argument
        ;;
      -drc | --delete-root-ca-certs)
        delete_root_ca_certs_flag='true'
        shift # past argument
        ;;
      -fta | --firefox-to-apt)
        firefox_to_apt_flag='true'
        shift # past argument
        ;;
      -go | --get-onion-domain)
        get_onion_domain_flag='true'
        shift # past argument
        ;;
      -grc | --get-root-ca-certificate)
        get_root_ca_certificate_into_client_flag='true'
        shift # past argument
        ;;
      -gsg | --get-server-gif)
        get_server_gif_into_client_flag='true'
        shift # past argument
        ;;
      -rcli | --record-cli)
        local record_cli_flag='true'
        cli_record_filename="$2"
        assert_is_non_empty_string "${cli_record_filename}"
        shift # past argument
        shift
        ;;
      -s | --services)
        services="$2"
        assert_is_non_empty_string "${services}"
        shift # past argument
        shift
        ;;
      -sp | --ssl-password)
        local ssl_password
        ssl_password="$2"
        assert_is_non_empty_string "${ssl_password}"
        shift # past argument
        shift
        ;;
      -ssc | --setup-ssh-client)
        setup_ssh_client_flag='true'
        shift
        ;;
      -ssso | --set-server-ssh-onion)
        local server_ssh_onion
        server_ssh_onion="$2"
        assert_is_non_empty_string "${server_ssh_onion}"
        shift # past argument
        shift
        ;;
      -ssu | --set-server-username)
        local server_username
        server_username="$2"
        assert_is_non_empty_string "${server_username}"
        shift # past argument
        shift
        ;;
      -v | --verbose)
        # shellcheck disable=SC2034
        VERBOSE='true'
        shift
        ;;
      -*)
        echo "Unknown option $1"
        print_usage
        exit 1
        ;;
    esac
  done

  check_prerequisites "$services"

  # Run the functions that are asked for in the CLI args.

  # Delete files from previous run.
  # TODO: allow running per service instead of for all services at once.
  process_delete_onion_domains_flag "$delete_onion_domain_flag"
  process_delete_ssl_cert_flags "$delete_projects_ssl_certs_flag" "$delete_root_ca_certs_flag"

  # TODO: move into: add to firefox part.
  # Prepare Firefox version.
  process_firefox_to_apt_flag "$firefox_to_apt_flag"

  manage_ssl_for_services "$services"

  process_get_file_from_server_into_client_flags "$get_root_ca_certificate_into_client_flag" "$get_server_gif_into_client_flag" "$server_username" "$server_ssh_onion"

  process_setup_ssh_client_flag "$setup_ssh_client_flag" "$server_username" "$server_ssh_onion"

  process_get_onion_domain_flag "$get_onion_domain_flag" "$services"

  process_record_cli_flag "$record_cli_flag" "$cli_record_filename"

  process_add_root_ca_to_ubuntu_flag "$add_root_ca_to_ubuntu_flag"
}
