#!/bin/bash
# Adds the private and public SSL certificates to the selfhosted GitLab.
# Optionally also adds root ca to GitLab.

# source src/GLOBAL_VARS.sh src/ssl_certs/add_public_private_ssl_cert_to_service/add_to_gitlab.sh && add_private_and_public_ssl_certs_to_gitlab "gitlab" "localhost" "cert-key.pem" "cert.pem" "ca.crt"
# source src/GLOBAL_VARS.sh src/ssl_certs/add_public_private_ssl_cert_to_service/add_to_gitlab.sh && add_private_and_public_ssl_certs_to_gitlab "gitlab" "onion_has_been_closed.onion" "cert-key.pem" "cert.pem" "ca.crt"
add_private_and_public_ssl_certs_to_gitlab() {
  local project_name="$1"
  local domain_name="$2"
  local ssl_private_key_filename="$3"
  local ssl_public_key_filename="$4"
  local ca_public_cert_filename="$5"
  local convert_to_crt_and_key_ext="$6"
  local include_root_ca_in_gitlab="$7"

  local ssl_private_key_filepath="certificates/ssl_cert/$project_name/$ssl_private_key_filename"
  local ssl_public_key_filepath="certificates/ssl_cert/$project_name/$ssl_public_key_filename"

  # Assert local private and public certificate exist for service.
  manual_assert_file_exists "$ssl_private_key_filepath"
  manual_assert_file_exists "$ssl_public_key_filepath"
  create_gitlab_ssl_directories "$domain_name"
  create_gitlab_ssl_directories_in_docker "$domain_name"

  local ssl_public_key_in_gitlab_filepath
  local ssl_private_key_in_gitlab_filepath

  local local_ssl_public_key_filepath
  local local_ssl_private_key_filepath

  if [[ "$convert_to_crt_and_key_ext" == "true" ]]; then

    # Convert public .pem into public .crt with:
    local_ssl_public_key_filepath="certificates/ssl_cert/$project_name/$domain_name.crt"
    local_ssl_private_key_filepath="certificates/ssl_cert/$project_name/$domain_name.key"
    openssl x509 -outform der -in "$ssl_public_key_filepath" -out "$local_ssl_public_key_filepath"
    manual_assert_file_exists "$local_ssl_public_key_filepath"

    # Convert private .pem into private .key with:
    openssl pkey -in "$ssl_private_key_filepath" -out "$local_ssl_private_key_filepath"
    manual_assert_file_exists "$local_ssl_private_key_filepath"
    # TODO: verify the generated .key is valid with the old public .pem.
    # TODO: verify the generated .key is valid with the new public .crt.

    ssl_public_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name/public_key.crt"
    ssl_private_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name/private_key.key"

  else
    ssl_public_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name/public_key.pem"
    ssl_private_key_in_gitlab_filepath="/etc/gitlab/ssl/$domain_name/private_key.pem"

    local_ssl_public_key_filepath="$ssl_public_key_filepath"
    local_ssl_private_key_filepath="$ssl_private_key_filepath"
  fi

  copy_ssl_certs_to_gitlab

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
  local domain_name="$1"
  sudo rm -rf "/etc/gitlab/ssl/*"
  sudo mkdir -p "/etc/gitlab/ssl"
  sudo chmod 755 "/etc/gitlab/ssl"
  sudo mkdir -p "/etc/gitlab/ssl/$domain_name/"
  sudo chmod 755 "/etc/gitlab/ssl/$domain_name/"
}

create_gitlab_ssl_directories_in_docker() {
  local domain_name="$1"

  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)

  sudo docker exec -i "$docker_container_id" bash -c "rm -rf \"/etc/gitlab/ssl/*\""
  sudo docker exec -i "$docker_container_id" bash -c "mkdir -p \"/etc/gitlab/ssl\""
  sudo docker exec -i "$docker_container_id" bash -c "chmod 755 \"/etc/gitlab/ssl\""
  sudo docker exec -i "$docker_container_id" bash -c "mkdir -p \"/etc/gitlab/ssl/$domain_name/\""
  sudo docker exec -i "$docker_container_id" bash -c "chmod 755 \"/etc/gitlab/ssl/$domain_name/\""
}

copy_ssl_certs_to_gitlab() {
  # Copy your new certificates into the folder where GitLab looks by default
  # for new SSL certificates. (OUTSIDE THE DOCKER.)
  sudo cp "$local_ssl_public_key_filepath" "$ssl_public_key_in_gitlab_filepath"
  sudo cp "$local_ssl_private_key_filepath" "$ssl_private_key_in_gitlab_filepath"
  manual_assert_file_exists "$ssl_public_key_in_gitlab_filepath"
  manual_assert_file_exists "$ssl_private_key_in_gitlab_filepath"

  assert_target_dir_exists_in_docker "/etc/gitlab/ssl/$domain_name/"
  # Assert target dir exists in docker.
  # Copy your new certificates into the folder where GitLab looks by default
  # for new SSL certificates. (OUTSIDE THE DOCKER.)
  copy_file_into_docker "$local_ssl_public_key_filepath" "$ssl_public_key_in_gitlab_filepath"
  copy_file_into_docker "$local_ssl_private_key_filepath" "$ssl_private_key_in_gitlab_filepath"
  read -p "copied ssl certs into docker."
}

assert_target_dir_exists_in_docker() {
  local target_dir="$1"

  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)

  local the_output
  the_output=$(sudo docker exec -i "$docker_container_id" bash -c "test -d $target_dir && echo 'FOUND'")
  if [[ "$the_output" != "FOUND" ]]; then
    echo "Error, did not find target directory:$target_dir."
    exit 5
  fi
  read -p "Verified target dir exists."
}

assert_target_file_exists_in_docker() {
  local target_filepath="$1"

  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)

  local the_output
  the_output=$(sudo docker exec -i "$docker_container_id" bash -c "test -f $target_filepath && echo 'FOUND'")
  if [[ "$the_output" != "FOUND" ]]; then
    echo "Error, did not find target directory:$target_filepath."
    exit 5
  fi
  read -p "Verified target dir exists."
}

copy_file_into_docker() {
  local local_filepath="$1"
  local docker_out_filepath="$2"

  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)

  # TODO: assert target directory exists.

  sudo docker cp "$local_filepath" "$docker_container_id":"$docker_out_filepath"

  # TODO: assert target file exists in docker.
  assert_target_file_exists_in_docker "$docker_out_filepath"
}

reconfigure_gitlab_with_new_certs_and_settings() {
  # Create a method to get the docker id.
  local docker_container_id
  docker_container_id=$(get_docker_container_id_of_gitlab_server)
  sudo docker exec -i "$docker_container_id" bash -c "gitlab-ctl reconfigure"
}

add_lines_to_gitlab_rb() {
  local domain_name="$1"
  local include_root_ca_in_gitlab="$2"
  local ssl_public_key_in_gitlab_filepath="$3"
  local ssl_private_key_in_gitlab_filepath="$4"

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
  echo "nginx['ssl_certificate_key'] = \"$ssl_private_key_in_gitlab_filepath\"" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  #echo "nginx['ssl_dhparam'] = \"/etc/gitlab/ssl/dhparams.pem\""  >> "$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  echo "nginx['listen_port'] = 80" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  echo "nginx['listen_https'] = true" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  if [[ "$include_root_ca_in_gitlab" == "true" ]]; then
    echo "nginx['ssl_client_certificate'] = \"/etc/gitlab/ssl/ca.crt\"" >>"$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"
  fi

  # TODO: verify the external url is found correctly:
  # sudo cat ~/gitlab/config/gitlab.rb | grep external_url

  tail -15 "$GITLAB_RB_TEMPLATE_DIR""gitlab.rb"

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
  docker_container_id=$(sudo docker ps -aqf "name=gitlab")
  assert_is_non_empty_string "$docker_container_id"

  echo "$docker_container_id"
}
