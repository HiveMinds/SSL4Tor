#!/bin/bash
source src/ssl_certs/add_public_private_ssl_cert_to_service/add_to_gitlab.sh # TODO: remove.
source src/verification/assert_exists.sh

# source src/ssl_certs/add_public_private_ssl_cert_to_service/verify_ssl_certs.sh && assert_certs_are_valid /home/qemu/SSL4Tor/certificates/ssl_cert/gitlab/localhost.crt /home/qemu/SSL4Tor/certificates/ssl_cert/gitlab/localhost.key

# source src/ssl_certs/add_public_private_ssl_cert_to_service/verify_ssl_certs.sh && assert_certs_are_valid /home/qemu/SSL4Tor/certificates/ssl_cert/gitlab/cert.pem /home/qemu/SSL4Tor/certificates/ssl_cert/gitlab/cert-key.pem
#openssl x509 -noout -modulus -in /home/qemu/SSL4Tor/certificates/ssl_cert/gitlab/cert-key.pem
#openssl x509 -noout -modulus -in cert-key.pem
# diff  <(openssl x509 -in cert.pem -pubkey -noout) <(openssl rsa -in cert-key.key -pubout)
#cmp <(openssl x509 -pubkey -in cert.pem -noout) <(openssl pkey -check -pubout -in cert-key.pem -outform PEM)
# openssl x509 -pubkey -in cert.pem -noout
# openssl pkey -check -pubout -in cert-key.pem
# openssl s_server -key cert-key.pem -cert cert.pem
assert_certs_are_valid() {
  local public_cert_filepath="$1"
  local private_key_filepath="$2"

  manual_assert_file_exists "$public_cert_filepath"
  manual_assert_file_exists "$private_key_filepath"

  local public_md5_output
  local public_md5
  local private_md5_output
  local private_md5

  #public_md5_output=$(openssl x509 -noout -modulus -in "$public_cert_filepath" | openssl md5)
  #private_md5_output=$(openssl rsa -noout -modulus -in "$private_key_filepath" | openssl md5)

  public_md5_output=$(openssl x509 -noout -modulus -in "$public_cert_filepath")
  private_md5_output=$(openssl rsa -noout -modulus -in "$private_key_filepath")

  #   public_md5="${public_md5_output:(-32)}"
  #   assert_is_alphanumeric "$public_md5"
  #   private_md5="${private_md5_output:(-32)}"
  #   assert_is_alphanumeric "$private_md5"

  if [[ "$public_md5" != "$public_md5" ]]; then
    echo "public_md5=$public_md5"
    echo "private_md5=$private_md5"
    echo "SSL certificates were not validated."
    exit 6
  fi
}

ssl_cert_verify() {
  local key="$1"
  local cert="$2"
  local opt="-check"
  cmp <(openssl x509 -pubkey -in "$cert" -noout) <(openssl pkey $opt -pubout -in "$key" -outform PEM)
}

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
