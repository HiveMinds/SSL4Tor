#!/bin/bash
# Adds the private and public SSL certificates to the selfhosted GitLab.
# Does not add root ca to anything.

# shellcheck disable=SC1091
source src/verification/assert_exists.sh # TODO: remove
#SSL_PRIVATE_KEY_FILENAME="cert-key.pem"
#SSL_PUBLIC_KEY_FILENAME="cert.pem"
# source src/ssl_certs/add_public_private_ssl_cert_to_service/add_to_gitlab.sh && add_private_and_public_ssl_certs_to_gitlab "gitlab" "localhost" "cert-key.pem" "cert.pem"
add_private_and_public_ssl_certs_to_gitlab() {
  local project_name="$1"
  local domain_name="$2"
  local ssl_private_key_filename="$3"
  local ssl_public_key_filename="$4"

  local ssl_private_key_filepath="certificates/ssl_cert/$project_name/$ssl_private_key_filename"
  local ssl_public_key_filepath="certificates/ssl_cert/$project_name/$ssl_public_key_filename"

  # Assert local private and public certificate exist for service.
  manual_assert_file_exists "$ssl_private_key_filepath"
  manual_assert_file_exists "$ssl_public_key_filepath"

  # Convert public .pem into public .crt with:
  openssl x509 -outform der -in "$ssl_public_key_filepath" -out "certificates/ssl_cert/$project_name/$domain_name.crt"

  # Convert private .pem into private .key with:
  openssl pkey -in "$ssl_private_key_filepath" -out "certificates/ssl_cert/$project_name/$domain_name.key"

  # Assert new local private and public certificate exist for service.
  manual_assert_file_exists "certificates/ssl_cert/$project_name/$domain_name.crt"
  manual_assert_file_exists "certificates/ssl_cert/$project_name/$domain_name.key"

  # TODO: verify the generated .key is valid with the old public .pem.
  # TODO: verify the generated .key is valid with the new public .crt.

  create_gitlab_ssl_directories

  # Copy your new certificates into the folder where GitLab looks by default
  # for new SSL certificates.
  sudo cp "certificates/ssl_cert/$project_name/$domain_name.crt" "/etc/gitlab/ssl/$domain_name.crt"
  sudo cp "certificates/ssl_cert/$project_name/$domain_name.key" "/etc/gitlab/ssl/$domain_name.key"

  manual_assert_file_exists "/etc/gitlab/ssl/$domain_name.crt"
  manual_assert_file_exists "/etc/gitlab/ssl/$domain_name.key"

  #sudo gitlab-ctl reconfigure
}

create_gitlab_ssl_directories() {
  sudo mkdir -p "/etc/gitlab/ssl"
  sudo chmod 755 "/etc/gitlab/ssl"
}
