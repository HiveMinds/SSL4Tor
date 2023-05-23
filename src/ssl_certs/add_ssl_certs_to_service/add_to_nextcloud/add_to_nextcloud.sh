#!/bin/bash

add_private_and_public_ssl_certs_to_nextcloud() {
  local project_name="$1"
  local domain_name="$2"
  local ssl_private_key_filename="$3"
  local ssl_public_key_filename="$4"
  local merged_ca_ssl_cert_filename="$5"

  add_certs_to_nextcloud "$project_name" "$ssl_public_key_filename" "$ssl_private_key_filename" "$merged_ca_ssl_cert_filename"

  # Ensures an onion url is created for Nextcloud.
  add_onion_to_nextcloud_trusted_domain "$domain_name"
}

add_onion_to_nextcloud_trusted_domain() {
  local domain_name="$1"

  # TODO: verify format of incoming onion address.

  #add Hidden Service address like a trusted domain in NextCloud instance
  # TODO: make 1 into 2 for onion domain, and 1 for localhost.
  read -p "domain_name=$domain_name"
  sudo /snap/bin/nextcloud.occ config:system:set trusted_domains 2 --value="$domain_name"
  green_msg "The Hidden Service address has been added like trusted domain successfully."

  # TODO: verify output:
  read -p "$(sudo /snap/bin/nextcloud.occ config:system:get trusted_domains)"
}

add_certs_to_nextcloud() {
  local project_name="$1"
  local ssl_public_key_filename="$2"
  local ssl_private_key_filename="$3"
  local merged_ca_ssl_cert_filename="$4"

  local ssl_private_key_filepath="certificates/ssl_cert/$project_name/$ssl_private_key_filename"
  local ssl_public_key_filepath="certificates/ssl_cert/$project_name/$ssl_public_key_filename"
  local merged_ca_ssl_cert_filepath="certificates/merged/$project_name/$merged_ca_ssl_cert_filename"

  # Assert local private and public certificate exist for service.
  manual_assert_file_exists "$ssl_private_key_filepath"
  manual_assert_file_exists "$ssl_public_key_filepath"
  manual_assert_file_exists "$merged_ca_ssl_cert_filepath"
  assert_certs_are_valid "$ssl_public_key_filepath" "$ssl_private_key_filepath"

  # First copy the files into nextcloud.
  # Source: https://github.com/nextcloud-snap/nextcloud-snap/issues/256
  # (see nextcloud.enable-https custom -h command).
  #sudo cp ca.pem /var/snap/nextcloud/current/ca.pem
  sudo cp "$ssl_private_key_filepath" /var/snap/nextcloud/current/"$ssl_private_key_filename"
  sudo cp "$ssl_public_key_filepath" /var/snap/nextcloud/current/"$ssl_public_key_filename"
  sudo cp "$merged_ca_ssl_cert_filepath" /var/snap/nextcloud/current/"$merged_ca_ssl_cert_filename"

  # Assert local private and public certificate exist for service.
  manual_assert_file_exists /var/snap/nextcloud/current/"$ssl_private_key_filename"
  manual_assert_file_exists /var/snap/nextcloud/current/"$ssl_public_key_filename"
  #assert_certs_are_valid /var/snap/nextcloud/current/"$ssl_public_key_filename" /var/snap/nextcloud/current/"$ssl_private_key_filename"

  # CLI sudo /snap/bin/nextcloud.enable-https custom Says:
  sudo /snap/bin/nextcloud.enable-https custom "/var/snap/nextcloud/current/$ssl_public_key_filename" "/var/snap/nextcloud/current/$ssl_private_key_filename" "/var/snap/nextcloud/current/$merged_ca_ssl_cert_filename"
  #sudo /snap/bin/nextcloud.enable-https custom "/var/snap/nextcloud/current/cert.pem" "/var/snap/nextcloud/current/cert-key.pem" "/var/snap/nextcloud/current/fullchain.pem"

  # sudo /snap/bin/nextcloud.enable-https self-signed
}
