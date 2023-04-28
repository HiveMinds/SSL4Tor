#!/bin/bash
# Adds the root ca certificate named ca.crt to an apt installation of Firefox.
# Adds the root ca certificate named ca.crt to a snap installation of Firefox.

add_self_signed_root_cert_to_firefox() {

  local policies_filepath="/etc/firefox/policies/policies.json"

  local policies_line="$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"

  if [ "$(file_exists $policies_filepath)" == "FOUND" ]; then

    if [ "$(file_contains_string "$policies_line" "$policies_filepath")" == "NOTFOUND" ]; then

      # Generate content to put in policies.json.
      local new_json_content
      # shellcheck disable=SC2086
      new_json_content=$(jq '.policies.Certificates += [{
                    "Install": ["'$policies_line'"]
               }]' $policies_filepath)

      # Append the content
      echo "$new_json_content" | sudo tee $policies_filepath >/dev/null

    else
      red_msg "Your certificate is already added to Firefox."
      exit 6
    fi
    # Assert the policy is in the file.
    if [ "$(file_contains_string "$policies_line" "$policies_filepath")" == "NOTFOUND" ]; then

      red_msg "Error, policy was not found in file:$policies_filepath"
      exit 5
    fi

    # Restart firefox.
    pkill firefox
    firefox &
  else

    yellow_msg "You have to add the self-signed root certificate authority to your"
    yellow_msg "browser yourself. Because I did not find a policies path at:$policies_filepath."

  fi
}

has_added_self_signed_root_ca_cert_to_apt_firefox() {
  # TODO: include snap firefox check.

  local policies_filepath="/etc/firefox/policies/policies.json"

  local policies_line="$UBUNTU_CERTIFICATE_DIR$CA_PUBLIC_CERT_FILENAME"

  if [ "$(file_exists $policies_filepath)" == "FOUND" ]; then
    if [ "$(file_contains_string "$policies_line" "$policies_filepath")" == "NOTFOUND" ]; then
      echo "NOTFOUND"
    elif [ "$(file_contains_string "$policies_line" "$policies_filepath")" == "FOUND" ]; then
      echo "FOUND"
    fi
  else
    echo "NOTFOUND"
  fi
}

assert_has_added_self_signed_root_ca_cert_to_apt_firefox() {
  if [[ "$(has_added_self_signed_root_ca_cert_to_apt_firefox)" != "FOUND" ]]; then
    echo "Error, root ca certificate was not added to apt Firefox."
    exit 6
  fi
}
