#!/bin/bash

# shellcheck disable=SC2153

make_root_ssl_certs() {
  local ssl_password="$1"

  # TODO: if files already exist, perform double check on whether user wants to
  # overwrite the files.

  delete_root_certificate
  create_root_certificate_directories

  # Generate and apply certificate.
  generate_root_ca_cert "$CA_PRIVATE_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$ssl_password"

  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

  copy_file "certificates/root/$CA_PUBLIC_KEY_FILENAME" "$ROOT_CA_PEM_PATH" "true"

  make_self_signed_root_cert_trusted_on_ubuntu

  # TODO: make argument optional.
  # TODO: include apt Firefox instead of snap.
  # add_self_signed_root_cert_to_firefox

  # Assert root CA files exist.

}

delete_root_certificate() {
  rm -f "certificates/root/$CA_PRIVATE_KEY_FILENAME"
  rm -f "certificates/root/$CA_PUBLIC_CERT_FILENAME"
  rm -f "certificates/root/$CA_PUBLIC_KEY_FILENAME"

  sudo rm -f "/usr/local/share/ca-certificates/$CA_PUBLIC_KEY_FILENAME"
  sudo rm -f "/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME"
  sudo rm -r "/usr/local/share/ca-certificates/"

  rm -f "$ROOT_CA_PEM_PATH"

  # TODO: put the pwd file outside of the repo.
  # TODO: pass pwd through commandline instead of via file.
  rm -f "$TEMP_SSL_PWD_FILENAME"
}

create_root_certificate_directories() {
  mkdir -p "certificates/root/"
}

assert_root_ca_files_exist() {
  echo "TODO"
}

generate_root_ca_cert() {
  local ca_private_key_filename="$1"
  local ca_public_key_filename="$2"
  local ssl_password="$3"

  echo "$ssl_password" >"$TEMP_SSL_PWD_FILENAME"

  # Generate RSA
  openssl genrsa -passout file:"$TEMP_SSL_PWD_FILENAME" -aes256 -out "certificates/root/$ca_private_key_filename" 4096

  # Generate a public CA Cert
  openssl req -passin file:"$TEMP_SSL_PWD_FILENAME" -subj "/C=$COUNTRY_CODE/" -new -x509 -sha256 -days 365 -key "certificates/root/$ca_private_key_filename" -out "certificates/root/$ca_public_key_filename"

  assert_root_ca_files_exist
}

install_the_ca_cert_as_a_trusted_root_ca() {
  local ca_public_key_filename="$1"
  local ca_public_cert_filename="$2"

  # The file in the ca-certificates dir must be of extension .crt, so convert it into that (as a copy):
  openssl x509 -outform der -in "certificates/root/$ca_public_key_filename" -out "certificates/root/$ca_public_cert_filename"

  # First remove any old cert if it pre-existed.
  sudo rm -f "/usr/local/share/ca-certificates/$ca_public_cert_filename"
  sudo update-ca-certificates

  # On Debian & Derivatives:
  #- Move the CA certificate (`"$ca_private_key_filename"`) into `/usr/local/share/ca-certificates/ca.crt`.
  manual_assert_dir_exists "/usr/local/share/ca-certificates/"
  sudo cp "certificates/root/$ca_public_cert_filename" "/usr/local/share/ca-certificates/$ca_public_cert_filename"
  manual_assert_file_exists "/usr/local/share/ca-certificates/$ca_public_cert_filename"

  # Update the Cert Store with:
  sudo update-ca-certificates
}

# On Android (This has been automated)
# 1. Open Phone Settings
# The exact steps vary device-to-device, but here is a generalised guide:
# 2. Locate `Encryption and Credentials` section. It is generally found under `Settings > Security > Encryption and Credentials`
# 3. Choose `Install a certificate`
# 4. Choose `CA Certificate`
# 5. Locate the certificate file `"$ca_private_key_filename"` on your SD Card/Internal Storage using the file manager.
# 6. Select to load it.
# 7. Done!

make_self_signed_root_cert_trusted_on_ubuntu() {
  # source: https://ubuntu.com/server/docs/security-trust-store
  # source: https://askubuntu.com/questions/73287/how-do-i-install-a-root-certificate

  ensure_apt_pkg "ca-certificates"

  sudo mkdir -p /usr/local/share/ca-certificates/

  sudo cp "certificates/root/$CA_PUBLIC_CERT_FILENAME" "/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME"
  manual_assert_file_exists "/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME"

  # TODO: determine whether these comments are relevant.
  # Add the .crt file's path relative to /usr/local/share/ca-certificates to:
  # /etc/ca-certificates.conf:
  #sudo dpkg-reconfigure ca-certificatesCA_PUBLIC_CERT_FILENAME

  sudo update-ca-certificates
  # Verify the ca is in the trusted ca-certificates dir with ca
  # certificates: /etc/ssl/certs(/ca.pem)
  manual_assert_file_exists "/etc/ssl/certs/$CA_PUBLIC_KEY_FILENAME"

}

add_self_signed_root_cert_to_firefox() {

  local policies_filepath="/etc/firefox/policies/policies.json"

  local policies_line="/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME"

  if [ "$(file_exists $policies_filepath)" == "FOUND" ]; then

    if [ "$(file_contains_string "$policies_line" "$policies_filepath")" == "NOTFOUND" ]; then

      # Generate content to put in policies.json.
      local new_json_content
      # shellcheck disable=SC2086
      new_json_content=$(jq '.policies.Certificates += [{
                    "Install": ["'$policies_line'"]
               }]' $policies_filepath)

      # Append the content
      echo "$new_json_content" | sudo tee $policies_filepath

    else
      echo "Your certificate is already added to Firefox."
    fi
    # Assert the policy is in the file.
    if [ "$(file_contains_string "$policies_line" "$policies_filepath")" == "NOTFOUND" ]; then
      echo "Error, policy was not found in file:$policies_filepath"
      exit 5
    fi

    # Restart firefox.
    pkill firefox
    firefox &
  else
    echo "You have to add the self-signed root certificate authority to your"
    echo "browser yourself."
  fi
}
