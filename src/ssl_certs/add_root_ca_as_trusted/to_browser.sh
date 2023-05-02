#!/bin/bash
# Helper functions to add root ca to browser.

add_self_signed_root_cert_to_browser() {
  local policies_filepath="$1"
  local browser_name="$2"

  local ubuntu_root_ca_filepath="$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"
  local new_json_content
  if [ "$(file_exists "$policies_filepath")" == "FOUND" ]; then

    if [ "$(file_contains_string "$ubuntu_root_ca_filepath" "$policies_filepath")" == "NOTFOUND" ]; then

      # Create a backup of the existing policies.
      mkdir -p "backups/$browser_name/"
      sudo rm "backups/$browser_name/policies.json"
      sudo cp "$policies_filepath" "backups/$browser_name/policies.json"

      # Generate content to put in policies.json.
      if [ "$(cat "$policies_filepath")" == "" ]; then
        new_json_content="$(create_policies_content_to_add_root_ca "$ubuntu_root_ca_filepath")"
      else

        # shellcheck disable=SC2086
        new_json_content=$(jq '.policies.Certificates += {
                      "Install": ["'$ubuntu_root_ca_filepath'"]
                 }' $policies_filepath)
      fi
      # Append the content
      echo "$new_json_content" | sudo tee "$policies_filepath" >/dev/null

    else
      red_msg "Your certificate is already added to Firefox."
      exit 6
    fi
  else
    new_json_content="$(create_policies_content_to_add_root_ca "$ubuntu_root_ca_filepath")"
    echo "$new_json_content" | sudo tee "$policies_filepath" >/dev/null
  fi

  # Assert the policy is in the file.
  if [ "$(file_contains_string "$ubuntu_root_ca_filepath" "$policies_filepath")" == "NOTFOUND" ]; then

    red_msg "Error, policy was not found in file:$policies_filepath" "true"
    exit 5
  fi

}

has_added_self_signed_root_ca_cert_to_browser() {
  local policies_filepath="$1"

  local ubuntu_root_ca_filepath="$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"

  # Assert the root project for this run/these services is created.
  if [ "$(file_exists "certificates/root/$CA_PUBLIC_CERT_FILENAME")" != "FOUND" ]; then
    echo "NOTFOUND"
    return 0
  fi
  if [ "$(file_exists "$ubuntu_root_ca_filepath")" != "FOUND" ]; then
    echo "NOTFOUND"
    return 0
  fi
  # Assert the root ca hash is as expected.
  if [[ "$(md5sum_is_identical "$ubuntu_root_ca_filepath" "certificates/root/$CA_PUBLIC_KEY_FILENAME")" != "FOUND" ]]; then
    echo "NOTFOUND"
    return 0
  fi

  if [ "$(file_exists "$policies_filepath")" == "FOUND" ]; then
    if [ "$(file_contains_string "$ubuntu_root_ca_filepath" "$policies_filepath")" == "NOTFOUND" ]; then
      echo "NOTFOUND"
      return 0
    elif [ "$(file_contains_string "$ubuntu_root_ca_filepath" "$policies_filepath")" == "FOUND" ]; then
      echo "FOUND"
      return 0
    fi
  else
    echo "NOTFOUND"
  fi
}

assert_has_added_self_signed_root_ca_cert_to_browser() {
  local policies_filepath="$1"
  if [[ "$(has_added_self_signed_root_ca_cert_to_browser "$policies_filepath")" != "FOUND" ]]; then
    echo "policies_filepath=$policies_filepath"
    echo "Error, root ca certificate was not added to apt Firefox."
    exit 6
  fi
}

close_restart_close_browser() {
  local browser_name="$1"
  # Close firefox.
  pkill "$browser_name" >>/dev/null 2>&1

  green_msg "Opening and closing $browser_name, please wait 3 seconds." "true"
  # TODO: Verify no errors occur when running $browser_name
  # TODO: Verify $browser_name was started successfully.
  nohup "$browser_name" >/dev/null 2>&1 &
  sleep 3

  pkill "$browser_name" >>/dev/null 2>&1
  green_msg "Proceeding with script." "true"
}

create_policies_content_to_add_root_ca() {
  local ubuntu_root_ca_filepath="$1"
  local inner
  inner=$(
    jq -n --argjson Install '["'"$ubuntu_root_ca_filepath"'"]' \
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
