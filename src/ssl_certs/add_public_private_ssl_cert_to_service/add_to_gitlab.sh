#!/bin/bash
# Adds the private and public SSL certificates to the selfhosted GitLab.
# Does not add root ca to anything.

# shellcheck disable=SC1091
source src/verification/assert_exists.sh # TODO: remove
#SSL_PRIVATE_KEY_FILENAME="cert-key.pem"
#SSL_PUBLIC_KEY_FILENAME="cert.pem"
# source src/GLOBAL_VARS.sh src/ssl_certs/add_public_private_ssl_cert_to_service/add_to_gitlab.sh && add_private_and_public_ssl_certs_to_gitlab "gitlab" "localhost" "cert-key.pem" "cert.pem" "ca.crt"
# source src/GLOBAL_VARS.sh src/ssl_certs/add_public_private_ssl_cert_to_service/add_to_gitlab.sh && add_private_and_public_ssl_certs_to_gitlab "gitlab" "onion_has_been_closed.onion" "cert-key.pem" "cert.pem" "ca.crt"
add_private_and_public_ssl_certs_to_gitlab() {
  local project_name="$1"
  local domain_name="$2"
  local ssl_private_key_filename="$3"
  local ssl_public_key_filename="$4"
  local ca_public_cert_filename="$5"

  local ssl_private_key_filepath="certificates/ssl_cert/$project_name/$ssl_private_key_filename"
  local ssl_public_key_filepath="certificates/ssl_cert/$project_name/$ssl_public_key_filename"

  # Assert local private and public certificate exist for service.
  manual_assert_file_exists "$ssl_private_key_filepath"
  manual_assert_file_exists "$ssl_public_key_filepath"
  create_gitlab_ssl_directories

  local convert_to_crt_and_key_ext="true"
  local include_root_ca_in_gitlab="true"

  local ssl_public_key_in_gitlab_filepath
  local ssl_private_key_in_gitlab_filepath

  if [[ "$convert_to_crt_and_key_ext" == "true" ]]; then

    # Convert public .pem into public .crt with:
    openssl x509 -outform der -in "$ssl_public_key_filepath" -out "certificates/ssl_cert/$project_name/$domain_name.crt"
    manual_assert_file_exists "certificates/ssl_cert/$project_name/$domain_name.crt"

    # Convert private .pem into private .key with:
    openssl pkey -in "$ssl_private_key_filepath" -out "certificates/ssl_cert/$project_name/$domain_name.key"
    manual_assert_file_exists "certificates/ssl_cert/$project_name/$domain_name.key"
    # TODO: verify the generated .key is valid with the old public .pem.
    # TODO: verify the generated .key is valid with the new public .crt.

    ssl_public_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name.crt"
    ssl_private_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name.key"

    # Copy your new certificates into the folder where GitLab looks by default
    # for new SSL certificates.
    sudo cp "certificates/ssl_cert/$project_name/$domain_name.crt" "$ssl_public_key_in_gitlab_filepath"
    sudo cp "certificates/ssl_cert/$project_name/$domain_name.key" "$ssl_private_key_in_gitlab_filepath"

  else
    ssl_public_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name/public_key.pem"
    ssl_private_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name/private_key.pem"

    sudo mkdir -p "/etc/gitlab/ssl/$domain_name/"
    sudo cp "$ssl_public_key_filepath" "$ssl_public_key_in_gitlab_filepath"
    sudo cp "$ssl_private_key_filepath" "$ssl_private_key_in_gitlab_filepath"
  fi

  manual_assert_file_exists "$ssl_public_key_in_gitlab_filepath"
  manual_assert_file_exists "$ssl_private_key_in_gitlab_filepath"

  # The ~/gitlab/config/gitlab.rb file says:
  ##! Most root CA's are included by default
  # nginx['ssl_client_certificate'] = "/etc/gitlab/ssl/ca.crt"
  # So perhaps also include the self-signed root ca into that dir.
  if [[ "$include_root_ca_in_gitlab" == "true" ]]; then
    manual_assert_file_exists "certificates/root/$ca_public_cert_filename"
    sudo cp "certificates/root/$ca_public_cert_filename" "/etc/gitlab/ssl/ca.crt"
    manual_assert_file_exists "/etc/gitlab/ssl/ca.crt"
  fi

  add_lines_to_gitlab_rb "$domain_name" "$include_root_ca_in_gitlab" "$ssl_public_key_in_gitlab_filepath" "$ssl_private_key_in_gitlab_filepath"

  reconfigure_gitlab_with_new_certs_and_settings

}

create_gitlab_ssl_directories() {
  sudo rm -rf "/etc/gitlab/ssl/*"
  sudo mkdir -p "/etc/gitlab/ssl"
  sudo chmod 755 "/etc/gitlab/ssl"
}

reconfigure_gitlab_with_new_certs_and_settings() {
  # Create a method to get the docker id.
  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)
  sudo docker exec -i "$docker_container_id" bash -c "gitlab-ctl reconfigure"
}

add_lines_to_gitlab_rb() {
  local domain_name="$1"
  local ssl_public_key_in_gitlab_filepath="$2"
  local ssl_private_key_in_gitlab_filepath="$3"

  # Create a copy of the basic gitlab.rb file.
  rm "$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  cp "$GITLAB_RB_TEMPLATE_FILEPATH" "$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  # Verified you only have to add lines (instead of modify) into that basic gitlab.rb.

  if [[ "$domain_name" == "localhost" ]]; then
    echo """external_url 'https://localhost'""" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  else
    echo "external_url '$domain_name'" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  fi
  # shellcheck disable=SC2129
  echo """letsencrypt['enable'] = false""" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"

  echo "nginx['enable'] = true" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  echo "nginx['redirect_http_to_https'] = true" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  echo "nginx['ssl_certificate'] = \"$ssl_public_key_in_gitlab_filepath\"" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  echo "nginx['ssl_certificate_key'] = \"$ssl_public_key_in_gitlab_filepath\"" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  #echo "nginx['ssl_dhparam'] = \"/etc/gitlab/ssl/dhparams.pem\""  >> "$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  echo "nginx['listen_port'] = 80" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  echo "nginx['listen_https'] = false" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  if [[ "$include_root_ca_in_gitlab" == "true" ]]; then
    echo "nginx['ssl_client_certificate'] = \"/etc/gitlab/ssl/ca.crt\"" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  fi

  # TODO: verify the external url is found correctly:
  # sudo cat ~/gitlab/config/gitlab.rb | grep external_url

  tail -15 "$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  # shellcheck disable=SC2162
  read -p "Is that as expected?"

  sudo cp "$GITLAB_RB_TEMPLATE_DIR""gitlab.rb" ~/gitlab/config/gitlab.rb
}

#######################################
#
# Local variables:
#
# Globals:
#  None.
# Arguments:
#
# Returns:
#  0 if
#  7 if
# Outputs:
#  None.
# TODO(a-t-0): change root with Global variable.
#######################################
# Structure:gitlab_docker
get_docker_container_id_of_gitlab_server() {
  local docker_container_id
  docker_container_id=$(sudo docker ps -aqf "name=containername")
  assert_is_non_empty_string "$docker_container_id"

  echo "$docker_container_id"
}
