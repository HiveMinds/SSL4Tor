#!/bin/bash

# To set up a self-signed SSL/HTTPS on a website you need to:
# 0. become the certificate authorateh (CA) (on your server/main device).
# 1. generate an SSL certificate based on the (CA) certificate you created.
# 2. make all your clients/other devices respect your own CA.

# In more details, analog to SSH, you create a private and public key pair.
# Next, each time someone visits your HTTPS website, you send them your public
# key. If they login to your HTTPS website, they encrypt their login username
# and password using your public key. Then your server receives the encrypted
# data and uses its own private key to decrypt it.

# The difference with SSH, is that besides encrypted data transmission, the
# browser of the person that visits your website also checks to see if they
# trust your server certificate authority(=a public certificate). Basically,
# the browser asks your website: "Who are you?", your server says: "I am this
# person (=self signed CA certificate)". Then the browser has its own list of
# people it knows. And if you self-sign, you are not in that list. That is why
# you need to make your clients add your self-signed CA certificate (so not the
# SSL certificate), to their list of "trusted Certificate Authorities".

# Now I can hear you thinking, "so my computer has a list of 6 billion friends
# (CA's) in it?". No, that would be inefficient. This is done hierarchically.
# There are root CA's, these sign certificates of certificate instances like,
# DigiCert, and Let's encrypt. And then Let's Encrypt gives normal users an
# (?SSL?) certificate, which any computer then knows comes from a trusted CA.

# Now this is where it gets interesting, I have some questions about this, in
# the past I read that some root CA was compromised, and cynical comments about
# how each root CA has probably a few three letter agency employees in it.
# What I do not yet know is, if one root CA is compromised whether all of its
# down-stream certificates are also automatically compromised, or not.

# Here is the list of certificates and their description:
# First you create your own certificate authority.
CA_PRIVATE_KEY_FILENAME="ca-key.pem"
CA_PUBLIC_KEY_FILENAME="ca.pem"
# Same file as ca.pem except different file extension and content.
CA_PUBLIC_CERT_FILENAME="ca.crt"

# Then you create a SSL certificate.
SSL_PRIVATE_KEY_FILENAME="cert-key.pem"

# Then create a sign-request (for your own CA to sign your own SSL certificate)
CA_SIGN_SSL_CERT_REQUEST_FILENAME="cert.csr"
SIGNED_DOMAINS_FILENAME="extfile.cnf"

# Then create the signed public SSL cert.
SSL_PUBLIC_KEY_FILENAME="cert.pem"

# Then merge the CA and SLL cert into one.
MERGED_CA_SSL_CERT_FILENAME="fullchain.pem"

TEMP_SSL_PWD_FILENAME="ssl_password.txt"
COUNTRY_CODE="FR"

USERNAME=$(whoami)
ROOT_CA_DIR="/home/$USERNAME"
ROOT_CA_PEM_PATH="$ROOT_CA_DIR/$CA_PUBLIC_KEY_FILENAME"

make_ssl_certs() {
  local onion_domain="$1"
  local project_name="$2"
  local ssl_password="$3"

  # TODO: if files already exist, perform double check on whether user wants to
  # overwrite the files.

  # Create domains accepted by certificate.
  local domains
  domains="DNS:localhost,DNS:$onion_domain"
  echo "domains=$domains.end_without_space"

  delete_target_files "$project_name"

  # Generate and apply certificate.
  generate_ca_cert "$CA_PRIVATE_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$ssl_password"

  generate_ssl_certificate "$CA_PUBLIC_KEY_FILENAME" "$CA_PRIVATE_KEY_FILENAME" "$CA_SIGN_SSL_CERT_REQUEST_FILENAME" "$SIGNED_DOMAINS_FILENAME" "$SSL_PUBLIC_KEY_FILENAME" "$SSL_PRIVATE_KEY_FILENAME" "$domains"

  verify_certificates "$CA_PUBLIC_KEY_FILENAME" "$SSL_PUBLIC_KEY_FILENAME"

  merge_ca_and_ssl_certs "$SSL_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$MERGED_CA_SSL_CERT_FILENAME"

  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

  copy_file "$CA_PUBLIC_KEY_FILENAME" "$ROOT_CA_PEM_PATH" "true"

  make_self_signed_root_cert_trusted_on_ubuntu "$project_name"

}

generate_ca_cert() {
  local ca_private_key_filename="$1"
  local ca_public_key_filename="$2"
  local ssl_password="$3"

  echo "$ssl_password" >"$TEMP_SSL_PWD_FILENAME"

  # Generate RSA
  openssl genrsa -passout file:$TEMP_SSL_PWD_FILENAME -aes256 -out "$ca_private_key_filename" 4096

  # Generate a public CA Cert
  openssl req -passin file:$TEMP_SSL_PWD_FILENAME -subj "/C=$COUNTRY_CODE/" -new -x509 -sha256 -days 365 -key "$ca_private_key_filename" -out "$ca_public_key_filename"

}

generate_ssl_certificate() {
  local ca_public_key_filename="$1"
  local ca_private_key_filename="$2"
  local ca_sign_ssl_cert_request_filename="$3"
  local signed_domains_filename="$4"
  local ssl_public_key_filename="$5"
  local ssl_private_key_filename="$6"
  local domains="$7"
  # Example supported domains:
  # DNS:your-dns.record,IP:257.10.10.1

  # Create a RSA key
  openssl genrsa -out "$ssl_private_key_filename" 4096

  # Create a Certificate Signing Request (CSR)
  openssl req -new -sha256 -subj "/CN=yourcn" -key "$ssl_private_key_filename" -out "$ca_sign_ssl_cert_request_filename"

  # Create a `extfile` with all the alternative names
  echo "subjectAltName=$domains" >>"$signed_domains_filename"

  # Create the public SSL certificate.
  openssl x509 -passin file:$TEMP_SSL_PWD_FILENAME -req -sha256 -days 365 -in "$ca_sign_ssl_cert_request_filename" -CA "$ca_public_key_filename" -CAkey "$ca_private_key_filename" -out "$ssl_public_key_filename" -extfile "$signed_domains_filename" -CAcreateserial

  rm "$TEMP_SSL_PWD_FILENAME"

}

verify_certificates() {
  local ca_public_key_filename="$1"
  local ssl_public_key_filename="$2"
  openssl verify -CAfile "$ca_public_key_filename" -verbose "$ssl_public_key_filename"
}

merge_ca_and_ssl_certs() {
  local ssl_public_key_filename="$1"
  local ca_public_key_filename="$2"
  local merged_ca_ssl_cert_filename="$3"

  cat "$ssl_public_key_filename" >"$merged_ca_ssl_cert_filename"
  cat "$ca_public_key_filename" >>"$merged_ca_ssl_cert_filename"
}

install_the_ca_cert_as_a_trusted_root_ca() {
  local ca_public_key_filename="$1"
  local ca_public_cert_filename="$2"

  # The file in the ca-certificates dir must be of extension .crt:
  openssl x509 -outform der -in "$ca_public_key_filename" -out "$ca_public_cert_filename"

  # First remove any old cert if it existed.
  sudo rm -f "/usr/local/share/ca-certificates/$ca_public_cert_filename"
  sudo update-ca-certificates

  # On Debian & Derivatives:
  #- Move the CA certificate (`"$ca_private_key_filename"`) into `/usr/local/share/ca-certificates/ca.crt`.
  manual_assert_dir_exists "/usr/local/share/ca-certificates/"
  sudo cp "$ca_public_cert_filename" "/usr/local/share/ca-certificates/$ca_public_cert_filename"
  manual_assert_file_exists "/usr/local/share/ca-certificates/$ca_public_cert_filename"

  # Update the Cert Store with:
  sudo update-ca-certificates
}

delete_target_files() {
  local project_name
  project_name="$1"
  rm -f "$CA_PRIVATE_KEY_FILENAME"
  rm -f "$CA_PUBLIC_CERT_FILENAME"
  rm -f "$CA_PUBLIC_KEY_FILENAME"
  rm -f "$SSL_PRIVATE_KEY_FILENAME"
  rm -f "$CA_SIGN_SSL_CERT_REQUEST_FILENAME"
  rm -f "$SIGNED_DOMAINS_FILENAME"
  rm -f "$SSL_PUBLIC_KEY_FILENAME"
  rm -f "$MERGED_CA_SSL_CERT_FILENAME"
  rm -f "$ROOT_CA_PEM_PATH"
  sudo rm -f "/usr/local/share/ca-certificates/$CA_PUBLIC_KEY_FILENAME"
  sudo rm -f "/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME"
  sudo rm -r "/usr/local/share/ca-certificates/$project_name"
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
  local project_name
  project_name="$1"

  ensure_apt_pkg "ca-certificates"

  sudo mkdir -p /usr/local/share/ca-certificates/"$project_name"

  sudo cp "$CA_PUBLIC_CERT_FILENAME" "/usr/local/share/ca-certificates/$project_name/$CA_PUBLIC_CERT_FILENAME"
  manual_assert_file_exists "/usr/local/share/ca-certificates/$project_name/$CA_PUBLIC_CERT_FILENAME"

  # TODO: determine whether these comments are relevant.
  # Add the .crt file's path relative to /usr/local/share/ca-certificates to:
  # /etc/ca-certificates.conf:
  #sudo dpkg-reconfigure ca-certificatesCA_PUBLIC_CERT_FILENAME

  sudo update-ca-certificates
  # Verify the ca is in the trusted ca-certificates dir with ca
  # certificates: /etc/ssl/certs(/ca.pem)
  manual_assert_file_exists "/etc/ssl/certs/$CA_PUBLIC_KEY_FILENAME"

  # TODO: make argument optional.
  # TODO: include apt Firefox instead of snap.
  # add_self_signed_root_cert_to_firefox
}

add_self_signed_root_cert_to_firefox() {
  local project_name
  project_name="$1"

  local policies_filepath="/etc/firefox/policies/policies.json"

  local policies_line="/usr/local/share/ca-certificates/$project_name/$CA_PUBLIC_CERT_FILENAME"

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
