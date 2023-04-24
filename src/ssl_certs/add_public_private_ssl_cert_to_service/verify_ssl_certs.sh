#!/bin/bash
source src/ssl_certs/add_public_private_ssl_cert_to_service/add_to_gitlab.sh # TODO: remove.
assert_certs_are_valid() {
  local public_cert_filepath="$1"
  local private_key_filepath="$2"

  local public_md5_output
  local public_md5
  local private_md5_output
  local private_md5
  public_md5_output=$(openssl x509 -noout -modulus -in "$public_cert_filepath" | openssl md5)
  private_md5_output=$(openssl x509 -noout -modulus -in "$private_key_filepath" | openssl md5)

  public_md5="${public_md5_output:(-32)}"
  assert_is_alphanumeric "$public_md5"
  private_md5="${private_md5_output:(-32)}"
  assert_is_alphanumeric "$private_md5"

  if [[ "$public_md5" != "$public_md5" ]]; then
    echo "public_md5=$public_md5"
    echo "private_md5=$private_md5"
    echo "SSL certificates were not validated."
    exit 6
  fi
}

# source src/ssl_certs/add_public_private_ssl_cert_to_service/verify_ssl_certs.sh && assert_certs_are_valid_within_docker localhost.crt localhost.key
assert_certs_are_valid_within_docker() {
  local public_cert_filepath="$1"
  local private_key_filepath="$2"

  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)

  local public_md5_output
  local public_md5
  local private_md5_output
  local private_md5

  public_md5_output=$(sudo docker exec -i "$docker_container_id" bash -c "openssl x509 -noout -modulus -in $public_cert_filepath | openssl md5")
  private_md5_output=$(sudo docker exec -i "$docker_container_id" bash -c "openssl x509 -noout -modulus -in $private_key_filepath | openssl md5")

  public_md5="${public_md5_output:(-32)}"
  assert_is_alphanumeric "$public_md5"
  private_md5="${private_md5_output:(-32)}"
  assert_is_alphanumeric "$private_md5"

  if [[ "$public_md5" != "$public_md5" ]]; then
    echo "public_md5=$public_md5"
    echo "private_md5=$private_md5"
    echo "SSL certificates were not validated."
    exit 6
  fi
}

is_alphanumeric() {
  local some_str="$1"

  # Verify it only contains lowercase letters (a to z).
  #grep '^[-0-9a-zA-Z]*$' <<<$1 ;
  #if [[ "$project_name" =~ ^[a-z]+$ ]]; then
  if [[ "$some_str" =~ ^[0-9a-z]+$ ]]; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

assert_is_alphanumeric() {
  local some_str="$1"

  if [[ "$(is_alphanumeric "$some_str")" != "FOUND" ]]; then
    echo "Error, $some_str is not purely alphanumeric."
    exit 5
  fi
}
