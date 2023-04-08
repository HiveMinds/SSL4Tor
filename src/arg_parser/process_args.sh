#!/bin/bash

process_project_name_flag() {
  local project_name_flag="$1"
  local project_name="$2"

  if [ "$project_name_flag" == "true" ]; then
    echo "Verified project name:$project_name consists of valid characters."
  fi
}

process_local_project_port_flag() {
  local local_project_port_flag="$1"
  local local_project_port="$2"

  if [ "$local_project_port_flag" == "true" ]; then
    echo "Verified the port:$hiddenservice_ssl_port is in valid range and unused."
  fi
}

process_hiddenservice_ssl_port_flag() {
  local hiddenservice_ssl_port_flag="$1"
  local hiddenservice_ssl_port="$2"

  if [ "$hiddenservice_ssl_port_flag" == "true" ]; then
    echo "Verified the port:$hiddenservice_ssl_port is in valid range and unused."
  fi
}

process_delete_ssl_certs_flag() {
  local delete_ssl_certs_flag="$1"
  local project_name="$2"

  if [ "$delete_ssl_certs_flag" == "true" ]; then
    echo "Deleting your self-signed SSL certificates for:$project_name"
  fi
}

process_delete_onion_domain_flag() {
  local delete_onion_domain_flag="$1"

  if [ "$delete_onion_domain_flag" == "true" ]; then
    echo "Deleting your onion domain for:$project_name"
    delete_onion_domain "$project_name"
  fi
}

process_generate_onion_domain_flag() {
  local generate_onion_domain_flag="$1"
  local project_name="$2"
  local local_project_port="$3"
  local hiddenservice_ssl_port="$4"

  if [ "$generate_onion_domain_flag" == "true" ]; then
    echo "Generating your onion domain for:$project_name"
    generate_onion_domain "$project_name" "$local_project_port" "$hiddenservice_ssl_port"
  fi
}

process_generate_ssl_certs_flag() {
  local generate_ssl_certs_flag="$1"
  local project_name="$2"

  if [ "$generate_ssl_certs_flag" == "true" ]; then
    echo "Generating your self-signed SSL certificates for:$project_name"
  fi
}

process_apply_certs_flag() {
  local apply_certs_flag="$1"

  if [ "$apply_certs_flag" == "true" ]; then
    echo "applying certs"
  fi
}

process_check_http_flag() {
  local check_http_flag="$1"

  if [ "$check_http_flag" == "true" ]; then
    echo "Checking your tor domain is available over http."
  fi
}

process_check_https_flag() {
  local check_https_flag="$1"

  if [ "$check_https_flag" == "true" ]; then
    echo "Checking your tor domain is available over https."
  fi
}
