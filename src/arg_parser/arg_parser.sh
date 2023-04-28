#!/bin/bash
parse_args() {
  # The incoming function arguments are the cli arguments.

  # Specify default argument values.
  local apply_certs_to_project_flag='false'
  local add_ssl_root_cert_to_apt_firefox_flag='false'
  local dont_use_ssl='false'
  local firefox_to_apt_flag='false'
  local get_root_ca_certificate_into_client_flag='false'
  local get_server_gif_into_client_flag='false'
  local make_project_ssl_certs_flag='false'
  local record_cli_flag='false'
  local setup_ssh_client_flag='false'
  local setup_ssh_server_flag='false'

  local convert_to_crt_and_key_ext='false'
  local include_root_ca_in_gitlab='false'

  # $# gives the length/number of the incoming function arguments.
  # the shift command eats the first element of that array, making it shorter.
  while [[ $# -gt 0 ]]; do
    case $1 in
      -a | --apply-certs)
        apply_certs_to_project_flag='true'
        shift # past argument
        ;;
      -asf | --add-ssl-root-cert-to-apt-firefox)
        add_ssl_root_cert_to_apt_firefox_flag='true'
        shift # past argument
        ;;
      -crt2key | --convert-pem-to-crt-and-key) # TODO: delete once valid setting is found.
        convert_to_crt_and_key_ext='true'
        shift # past argument
        ;;
      -ar2g | --add-root-to-gitlab) # TODO: delete once valid setting is found.
        include_root_ca_in_gitlab='true'
        shift # past argument
        ;;
      -do | --delete-onion-domain)
        delete_onion_domain_flag='true'
        shift # past argument
        ;;
      -ds | --delete-ssl-certs)
        delete_projects_ssl_certs_flag='true'
        shift # past argument
        ;;
      -dus | --dont-use-ssl)
        dont_use_ssl='true'
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
      -ms | --make-ssl-certs)
        make_project_ssl_certs_flag='true'
        shift # past argument
        ;;
      -mo | --make-onion-domains)
        make_onion_domain_flag='true'
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
      -sss | --setup-ssh-server)
        setup_ssh_server_flag='true'
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

  if [ "$dont_use_ssl" == "true" ]; then
    echo "Error, using http only is currently not supported."
    exit 5
  fi

  check_prerequisites "$services"

  # TODO: move into deletion management.
  # Run the functions that are asked for in the CLI args.
  # Delete files from previous run.
  process_delete_onion_domain_flag "$delete_onion_domain_flag"
  process_delete_projects_ssl_certs_flag "$delete_projects_ssl_certs_flag"

  # TODO: move into: add to firefox part.
  # Prepare Firefox version.
  process_firefox_to_apt_flag "$firefox_to_apt_flag"

  # TODO: move into default project processing.
  # Create onion domain(s).
  process_make_onion_domain_flag "$make_onion_domain_flag" "$services"

  # TODO: move into default project processing.
  # Create SSL certificates.
  process_make_project_ssl_certs_flag "$make_project_ssl_certs_flag" "$services" "$ssl_password"
  # TODO: move into default project processing.
  process_apply_certs_to_project_flag "$apply_certs_to_project_flag" "$services" "$convert_to_crt_and_key_ext" "$include_root_ca_in_gitlab"

  # Add self-signed ssl certificate to (apt) Firefox.
  # TODO: process services instead of project_name.
  process_add_ssl_root_cert_to_apt_firefox_flag "$add_ssl_root_cert_to_apt_firefox_flag" "$services"

  # TODO: move into default project processing.
  process_setup_ssh_server_flag "$setup_ssh_server_flag"
  # TODO: move into default project processing.
  process_setup_ssh_client_flag "$setup_ssh_client_flag" "$server_username" "$server_ssh_onion"

  process_get_file_from_server_into_client_flags "$get_root_ca_certificate_into_client_flag" "$get_server_gif_into_client_flag" "$server_username" "$server_ssh_onion"

  process_get_onion_domain_flag "$get_onion_domain_flag" "$services"

  process_record_cli_flag "$record_cli_flag" "$cli_record_filename"
}
