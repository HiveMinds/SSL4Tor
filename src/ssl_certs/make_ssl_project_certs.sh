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
# the past I read that some root CA was compromised (comodo and diginotar).
# There are different types of compromises. The private key of the root CA can
# be leaked, which allows malicious actors to create fake SSL certificates. It
# is not clear to me whether just having the private key is enough to spread
# those fake SSL certificates, or whether that requires an additional
# privilege. No leaks of private keys of CA's are known. Another form of
# compromise is the ability of malicious actors to get fake/bad SSL
# certificates signed by a CA (or 1 level below the root CA), (without the
# malicious actors having the private key of the root CA). This apparently
# happened to diginotar and comodo. It is not clear to me how those
# certificates got spread, nor what the impact of such a malicious SSL
# certificate is.

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

# Then merge the CA and SSL cert into one.
MERGED_CA_SSL_CERT_FILENAME="fullchain.pem"

TEMP_SSL_PWD_FILENAME="ssl_password.txt"
# shellcheck disable=SC2034 # (used in make_ssl_root_certs.sh)
COUNTRY_CODE="FR"

USERNAME=$(whoami)
ROOT_CA_DIR="/home/$USERNAME"
ROOT_CA_PEM_PATH="$ROOT_CA_DIR/$CA_PUBLIC_KEY_FILENAME"

make_project_ssl_certs() {
  local onion_domain="$1"
  local project_name="$2"
  local ssl_password="$3"

  # TODO: if files already exist, perform double check on whether user wants to
  # overwrite the files.

  # Create domains accepted by certificate.
  local domains
  domains="DNS:localhost,DNS:$onion_domain"
  echo "domains=$domains.end_without_space"

  delete_project_ssl_cert_files "$project_name"
  create_ssl_cert_storage_directories "$project_name"

  # Assert root CA files exist.

  # Generate and apply certificate.
  generate_root_ca_cert "$CA_PRIVATE_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$ssl_password"

  generate_project_ssl_certificate "$CA_PUBLIC_KEY_FILENAME" "$CA_PRIVATE_KEY_FILENAME" "$CA_SIGN_SSL_CERT_REQUEST_FILENAME" "$SIGNED_DOMAINS_FILENAME" "$SSL_PUBLIC_KEY_FILENAME" "$SSL_PRIVATE_KEY_FILENAME" "$domains"

  verify_certificates "$CA_PUBLIC_KEY_FILENAME" "$SSL_PUBLIC_KEY_FILENAME"

  merge_ca_and_ssl_certs "$SSL_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$MERGED_CA_SSL_CERT_FILENAME"

  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

  copy_file "certificates/root/$CA_PUBLIC_KEY_FILENAME" "$ROOT_CA_PEM_PATH" "true"

  make_self_signed_root_cert_trusted_on_ubuntu "$project_name"

}

delete_project_ssl_cert_files() {
  local project_name="$1"

  rm -f "certificates/ssl_cert/$project_name/$SSL_PRIVATE_KEY_FILENAME"
  rm -f "certificates/ssl_cert/$project_name/sign_request/$CA_SIGN_SSL_CERT_REQUEST_FILENAME"
  rm -f "certificates/ssl_cert/$project_name/sign_request/$SIGNED_DOMAINS_FILENAME"
  rm -f "certificates/ssl_cert/$project_name/$SSL_PUBLIC_KEY_FILENAME"
  rm -f "certificates/merged/$project_name/$MERGED_CA_SSL_CERT_FILENAME"
  rm -f "$ROOT_CA_PEM_PATH"

  # TODO: put the pwd file outside of the repo.
  # TODO: pass pwd through commandline instead of via file.
  rm -f "$TEMP_SSL_PWD_FILENAME"
}

create_ssl_cert_storage_directories() {
  local project_name="$1"
  mkdir -p "certificates/ssl_cert/$project_name/sign_request/"
  mkdir -p "certificates/merged/$project_name/"
}

generate_project_ssl_certificate() {
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
  openssl genrsa -out "certificates/ssl_cert/$project_name/$ssl_private_key_filename" 4096

  # Create a Certificate Signing Request (CSR)
  openssl req -new -sha256 -subj "/CN=yourcn" -key "certificates/ssl_cert/$project_name/$ssl_private_key_filename" -out "certificates/ssl_cert/$project_name/sign_request/$ca_sign_ssl_cert_request_filename"

  # Create a `extfile` with all the alternative names
  echo "subjectAltName=$domains" >>"certificates/ssl_cert/$project_name/sign_request/$signed_domains_filename"

  # Create the public SSL certificate.
  openssl x509 -passin file:$TEMP_SSL_PWD_FILENAME -req -sha256 -days 365 -in "certificates/ssl_cert/$project_name/sign_request/$ca_sign_ssl_cert_request_filename" -CA "certificates/root/$ca_public_key_filename" -CAkey "certificates/root/$ca_private_key_filename" -out "certificates/ssl_cert/$project_name/$ssl_public_key_filename" -extfile "certificates/ssl_cert/$project_name/sign_request/$signed_domains_filename" -CAcreateserial

  rm "$TEMP_SSL_PWD_FILENAME"

}

verify_certificates() {
  local ca_public_key_filename="$1"
  local ssl_public_key_filename="$2"
  openssl verify -CAfile "/certificates/root/$ca_public_key_filename" -verbose "certificates/ssl_cert/$project_name/$ssl_public_key_filename"
}

merge_ca_and_ssl_certs() {
  local ssl_public_key_filename="$1"
  local ca_public_key_filename="$2"
  local merged_ca_ssl_cert_filename="$3"

  cat "$ssl_public_key_filename" >"certificates/merged/$project_name/$merged_ca_ssl_cert_filename"
  cat "/certificates/root/$ca_public_key_filename" >>"certificates/merged/$project_name/$merged_ca_ssl_cert_filename"
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
