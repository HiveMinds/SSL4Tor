#!/bin/bash
parse_args() {
  # The incoming function arguments are the cli arguments.

  # Specify default argument values.
  local apply_certs_flag='false'
  local add_to_apt_firefox_flag='false'
  local check_http_flag='false'
  local check_https_flag='false'
  local firefox_to_apt_flag='false'
  local make_ssl_certs_flag='false'
  local project_name_flag='false'
  local local_project_port_flag='false'
  local use_ssl_flag='false'

  # $# gives the length/number of the incoming function arguments.
  # the shift command eats the first element of that array, making it shorter.
  while [[ $# -gt 0 ]]; do
    case $1 in
      -a | --apply-certs)
        apply_certs_flag='true'
        shift # past argument
        ;;
      -af | --add-to-apt-firefox)
        add_to_apt_firefox_flag='true'
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
      -ppo | --public_port_to_access_onion)
        public_port_to_access_onion_flag='true'
        # Assign default public_port_to_access_onion if none is specified in CLI.
        public_port_to_access_onion="$2"
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
      -sp | --ssl-password)
        local ssl_password
        ssl_password="$2"
        assert_is_non_empty_string "${ssl_password}"
        shift # past argument
        shift
        ;;
      -lpp | --local-project-port)
        local_project_port_flag='true'
        local_project_port="$2"
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

  # Ensure ports are populated.
  if [[ "$local_project_port" == "" ]]; then
    local_project_port="$DEFAULT_LOCAL_PROJECT_PORT"
  fi
  assert_is_non_empty_string "${local_project_port}"

  if [[ "$public_port_to_access_onion" == "" ]]; then
    if [[ "$use_ssl_flag" == "true" ]]; then
      public_port_to_access_onion="$PUBLIC_PORT_TO_ACCESS_ONION_SITE_WITH_SSL"
    else
      public_port_to_access_onion="$PUBLIC_PORT_TO_ACCESS_ONION_SITE_WITHOUT_SSL"
    fi
  fi
  assert_is_non_empty_string "${public_port_to_access_onion}"

  # Run the functions that are asked for in the CLI args.
  process_project_name_flag "$project_name_flag" "$project_name"
  process_local_project_port_flag "$local_project_port_flag" "$local_project_port"
  process_public_port_to_access_onion_flag "$public_port_to_access_onion_flag" "$public_port_to_access_onion"

  process_delete_onion_domain_flag "$delete_onion_domain_flag" "$project_name"
  process_delete_ssl_certs_flag "$delete_ssl_certs_flag"

  process_firefox_to_apt_flag "$firefox_to_apt_flag"
  process_add_to_apt_firefox_flag "$add_to_apt_firefox_flag" "$project_name"
  process_get_onion_domain_flag "$get_onion_domain_flag"
  process_make_onion_domain_flag "$make_onion_domain_flag" "$project_name" "$local_project_port" "$public_port_to_access_onion"
  process_make_ssl_certs_flag "$make_ssl_certs_flag" "$project_name" "$ssl_password"
  process_apply_certs_flag "$apply_certs_flag"
  process_check_http_flag "$check_http_flag"
  process_check_https_flag "$check_https_flag"

}
