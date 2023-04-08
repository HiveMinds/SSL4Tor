#!/bin/bash
parse_args() {
  # The incoming function arguments are the cli arguments.

  # Specify default argument values.
  local apply_certs_flag='false'
  local check_http_flag='false'
  local check_https_flag='false'
  local generate_ssl_certs_flag='false'
  local project_name_flag='false'
  local local_project_port_flag='false'

  # $# gives the length/number of the incoming function arguments.
  # the shift command eats the first element of that array, making it shorter.
  while [[ $# -gt 0 ]]; do
    case $1 in
      -a | --apply-certs)
        apply_certs_flag='true'
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
      -gs | --generate-ssl-certs)
        generate_ssl_certs_flag='true'
        shift # past argument
        ;;
      -go | --generate-onion-domain)
        generate_onion_domain_flag='true'
        shift # past argument
        ;;
      -hps | --hiddenservice_ssl_port)
        hiddenservice_ssl_port_flag='true'
        # Assign default hiddenservice_ssl_port if none is specified in CLI.
        hiddenservice_ssl_port="$2"
        shift # past argument
        shift
        ;;
      -n | --project-name)
        project_name_flag='true'
        project_name="$2"
        assert_is_non_empty_string "${project_name}"
        shift # past argument
        shift
        ;;
      -lpp | --local-project-port)
        local_project_port_flag='true'
        local_project_port="$2"
        shift # past argument
        shift
        ;;
      -*)
        echo "Unknown option $1"
        print_usage
        exit 1
        ;;
    esac
  done

  # Ensure ports are populated.
  if [[ "$local_project_port" == "" ]]; then
    local_project_port="$DEFAULT_LOCAL_PROJECT_PORT"
  fi
  assert_is_non_empty_string "${local_project_port}"

  if [[ "$hiddenservice_ssl_port" == "" ]]; then
    hiddenservice_ssl_port="$DEFAULT_HIDDENSERVICE_SSL_PORT"
  fi
  assert_is_non_empty_string "${hiddenservice_ssl_port}"

  # Run the functions that are asked for in the CLI args.
  process_project_name_flag "$project_name_flag" "$project_name"
  process_local_project_port_flag "$local_project_port_flag" "$local_project_port"
  process_hiddenservice_ssl_port_flag "$hiddenservice_ssl_port_flag" "$hiddenservice_ssl_port"
  process_delete_onion_domain_flag "$delete_onion_domain_flag" "$project_name"
  process_delete_ssl_certs_flag "$delete_ssl_certs_flag"
  process_generate_onion_domain_flag "$generate_onion_domain_flag" "$project_name" "$local_project_port" "$hiddenservice_ssl_port"
  process_generate_ssl_certs_flag "$generate_ssl_certs_flag"
  process_apply_certs_flag "$apply_certs_flag"
  process_check_http_flag "$check_http_flag"
  process_check_https_flag "$check_https_flag"

}
