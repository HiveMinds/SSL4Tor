#!/bin/bash
# Adds the root ca certificate named ca.crt to the apt or snap installation of Firefox.

add_self_signed_root_cert_to_firefox() {

  local policies_filepath
  policies_filepath=$(get_firefox_policies_path)

  local root_ca_filepath="$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"

  if [ "$(file_exists "$policies_filepath")" == "FOUND" ]; then

    if [ "$(file_contains_string "$root_ca_filepath" "$policies_filepath")" == "NOTFOUND" ]; then

      # Create a backup of the existing policies.
      sudo rm backups/policies.json
      sudo cp "$policies_filepath" backups/policies.json

      # Generate content to put in policies.json.
      local new_json_content
      # shellcheck disable=SC2086
      new_json_content=$(jq '.policies.Certificates += {
                    "Install": ["'$root_ca_filepath'"]
               }' $policies_filepath)

      # Append the content
      echo "$new_json_content" | sudo tee "$policies_filepath" >/dev/null

    else
      red_msg "Your certificate is already added to Firefox."
      exit 6
    fi
  else
    new_json_content="$(create_policies_content_to_add_root_ca "$root_ca_filepath")"
    echo "$new_json_content" | sudo tee "$policies_filepath" >/dev/null
  fi

  # Assert the policy is in the file.
  if [ "$(file_contains_string "$root_ca_filepath" "$policies_filepath")" == "NOTFOUND" ]; then

    red_msg "Error, policy was not found in file:$policies_filepath" "true"
    exit 5
  fi

}

has_added_self_signed_root_ca_cert_to_firefox() {
  local policies_filepath
  policies_filepath=$(get_firefox_policies_path)

  local root_ca_filepath="$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"

  # Assert the root project for this run/these services is created.
  if [ "$(file_exists "certificates/root/$CA_PUBLIC_CERT_FILENAME")" != "FOUND" ]; then
    echo "NOTFOUND"
    return 0
  fi
  if [ "$(file_exists "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME")" != "FOUND" ]; then
    echo "NOTFOUND"
    return 0
  fi
  # Assert the root ca hash is as expected.
  if [[ "$(md5sum_is_identical "$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME" "certificates/root/$CA_PUBLIC_CERT_FILENAME")" != "FOUND" ]]; then
    echo "NOTFOUND"
    return 0
  fi

  if [ "$(file_exists "$policies_filepath")" == "FOUND" ]; then
    if [ "$(file_contains_string "$root_ca_filepath" "$policies_filepath")" == "NOTFOUND" ]; then
      echo "NOTFOUND"
      return 0
    elif [ "$(file_contains_string "$root_ca_filepath" "$policies_filepath")" == "FOUND" ]; then
      echo "FOUND"
      return 0
    fi
  else
    echo "NOTFOUND"
  fi
}

assert_has_added_self_signed_root_ca_cert_to_firefox() {
  if [[ "$(has_added_self_signed_root_ca_cert_to_firefox)" != "FOUND" ]]; then
    echo "Error, root ca certificate was not added to apt Firefox."
    exit 6
  fi
}

firefox_is_installed() {
  if [[ "$(firefox_is_installed_with_apt)" == "FOUND" ]]; then
    echo "FOUND"
  elif [[ "$(firefox_is_installed_with_snap)" == "FOUND" ]]; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

firefox_is_installed_with_apt() {
  if dpkg -l firefox &>/dev/null; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

firefox_is_installed_with_snap() {
  if snap list | grep -v firefox &>/dev/null; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

get_firefox_policies_path() {
  local policies_filepath
  if dpkg -l firefox &>/dev/null; then
    # policies_filepath="/usr/lib/firefox/distribution/policies.json"
    policies_filepath="/etc/firefox/policies/policies.json"
  elif snap list | grep -v firefox &>/dev/null; then
    policies_filepath="/snap/firefox/current/distribution/policies.json"
  else
    echo "Error, firefox installation was not found."
    exit 6
  fi
  echo "$policies_filepath"
}

create_policies_content_to_add_root_ca() {
  local root_ca_filepath="$1"
  local inner
  inner=$(
    jq -n --argjson Install '["'"$root_ca_filepath"'"]' \
      '$ARGS.named'
  )

  local medium
  medium=$(
    jq -n --argjson Certificates "$inner" \
      '$ARGS.named'
  )

  local final
  final=$(
    jq -n --argjson policies "$medium" \
      '$ARGS.named'
  )

  echo "$final"
  # Desired output (created with jq as exercise, and for modularity):
  # {
  # "policies": {
  # "Certificates": {
  #     "Install": [
  #                "/usr/local/share/ca-certificates/ca.crt"
  #                ]
  #          }
  #     }
  # }
}

close_restart_close_firefox() {
  # Close firefox.
  pkill firefox >>/dev/null 2>&1

  green_msg "Opening and closing Firefox, please wait 3 seconds." "true"
  # TODO: Verify no errors occur when running Firefox.
  # TODO: Verify Firefox was started successfully.
  nohup firefox >/dev/null 2>&1 &
  sleep 3

  pkill firefox >>/dev/null 2>&1
  green_msg "Proceeding with script." "true"
}
