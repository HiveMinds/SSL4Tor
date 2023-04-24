#!/bin/bash
assert_certs_are_valid() {
  local public_cert_filepath="$1"
  local private_key_filepath="$2"

  manual_assert_file_exists "$public_cert_filepath"
  manual_assert_file_exists "$private_key_filepath"

  local public_md5_modulus
  local private_md5_modulus

  public_md5_modulus=$(openssl x509 -noout -modulus -in "$public_cert_filepath")
  private_md5_modulus=$(openssl rsa -noout -modulus -in "$private_key_filepath")

  if [[ "$public_md5_modulus" != "$private_md5_modulus" ]]; then
    echo "public_md5=$public_md5_modulus"
    echo "private_md5=$private_md5_modulus"
    echo "SSL certificates were not validated."
    exit 6
  fi
}

assert_certs_are_valid_within_docker() {
  local public_cert_filepath="$1"
  local private_key_filepath="$2"

  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)

  manual_assert_file_exists "$public_cert_filepath"
  manual_assert_file_exists "$private_key_filepath"

  local public_md5_modulus
  local private_md5_modulus

  public_md5_modulus=$(sudo docker exec -i "$docker_container_id" bash -c "openssl x509 -noout -modulus -in $public_cert_filepath")
  private_md5_modulus=$(sudo docker exec -i "$docker_container_id" bash -c "openssl rsa -noout -modulus -in $private_key_filepath")

  if [[ "$public_md5_modulus" != "$private_md5_modulus" ]]; then
    echo "public_md5=$public_md5_modulus"
    echo "private_md5=$private_md5_modulus"
    echo "SSL certificates were not validated."
    exit 6
  fi
}
