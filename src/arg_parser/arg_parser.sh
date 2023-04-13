#!/bin/bash
parse_args() {
  # The incoming function arguments are the cli arguments.

  # Specify default argument values.
  local apply_certs_to_project_flag='false'
  local add_ssl_root_cert_to_apt_firefox_flag='false'
  local check_http_flag='false'
  local check_https_flag='false'
  local firefox_to_apt_flag='false'
  local make_ssl_certs_flag='false'
  local one_domain_per_service_flag='false'
  local project_name_flag='false'
  local local_project_port_flag='false'
  local services_flag='false'
  local use_ssl_flag='false'

  # $# gives the length/number of the incoming function arguments.
  # the shift command eats the first element of that array, making it shorter.
  while [[ $# -gt 0 ]]; do
    case $1 in
      -1d1s | --1-domain-1-service)
        one_domain_per_service_flag='true'
        shift # past argument
        ;;
      -a | --apply-certs)
        apply_certs_to_project_flag='true'
        shift # past argument
        ;;
      -asf | --add-ssl-root-cert-to-apt-firefox)
        add_ssl_root_cert_to_apt_firefox_flag='true'
        shift # past argument
        ;;
      -ch | --check-http)
        check_http_flag='true'
        shift # past argument
        ;;
      -cs | --check-https)
        check_https_flag='true'
        shift # past argument
        ;;
      -ds | --delete-ssl-certs)
        delete_ssl_certs_flag='true'
        shift # past argument
        ;;
      -do | --delete-onion-domain)
        delete_onion_domain_flag='true'
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
      -ms | --make-ssl-certs)
        make_ssl_certs_flag='true'
        shift # past argument
        ;;
      -mo | --make-onion-domain)
        make_onion_domain_flag='true'
        shift # past argument
        ;;
      -s | --services)
        services_flag='true'
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
      -us | --use-ssl)
        use_ssl_flag='true'
        shift # past argument
        ;;
      -*)
        echo "Unknown option $1"
        print_usage
        exit 1
        ;;
    esac
  done

  # Ensure ports are populated and valid, and that project names are valid.
  assert_services_are_valid "$services"
  
  # Run the functions that are asked for in the CLI args.
  # Delete files from previous run.
  # TODO: make independent of project_name.
  process_delete_onion_domain_flag "$delete_onion_domain_flag" "$services"
  process_delete_ssl_certs_flag "$delete_ssl_certs_flag"

  # Prepare Firefox version.
  process_firefox_to_apt_flag "$firefox_to_apt_flag"

  # Create onion domain(s).
  process_make_onion_domain_flag "$make_onion_domain_flag" "$one_domain_per_service_flag" "$services"
  process_get_onion_domain_flag "$get_onion_domain_flag"
  # Verify http access to onion domain.
  process_check_http_flag "$check_http_flag"

  # Create SSL certificates.
  # TODO: process services instead of project_name.
  process_make_ssl_certs_flag "$make_ssl_certs_flag" "$one_domain_per_service_flag" "$services" "$ssl_password"
  process_apply_certs_to_project_flag "$apply_certs_to_project_flag"
  # Verify https access to onion domain.
  process_check_https_flag "$check_https_flag"

  # Add self-signed ssl certificate to (apt) Firefox.
  # TODO: process services instead of project_name.
  process_add_ssl_root_cert_to_apt_firefox_flag "$add_ssl_root_cert_to_apt_firefox_flag" "$services"

}
