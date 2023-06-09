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
# shellcheck disable=SC2034
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
# shellcheck disable=SC2034
OUTPUT_PUBLIC_ROOT_CERT_FILEPATH="$ROOT_CA_DIR/$CA_PUBLIC_CERT_FILENAME"

# shellcheck disable=SC2034
UBUNTU_CERTIFICATE_DIR="/usr/local/share/ca-certificates/"

make_project_ssl_certs() {
  local onion_domain="$1"
  local project_name="$2"

  # TODO: if files already exist, perform double check on whether user wants to
  # overwrite the files.

  # Create domains accepted by certificate.
  local domains
  domains="DNS:localhost,DNS:$onion_domain"

  delete_project_ssl_cert_files "$project_name"
  create_ssl_cert_storage_directories "$project_name"

  # Assert root CA files exist.

  generate_project_ssl_certificate "$CA_PUBLIC_KEY_FILENAME" "$CA_PRIVATE_KEY_FILENAME" "$CA_SIGN_SSL_CERT_REQUEST_FILENAME" "$SIGNED_DOMAINS_FILENAME" "$SSL_PUBLIC_KEY_FILENAME" "$SSL_PRIVATE_KEY_FILENAME" "$domains"

  verify_certificates "$CA_PUBLIC_KEY_FILENAME" "$SSL_PUBLIC_KEY_FILENAME"

  merge_ca_and_ssl_certs "$project_name" "$SSL_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$MERGED_CA_SSL_CERT_FILENAME"

}

delete_project_ssl_cert_files() {
  local project_name="$1"

  rm -f "certificates/ssl_cert/$project_name/$SSL_PRIVATE_KEY_FILENAME"
  rm -f "certificates/ssl_cert/$project_name/sign_request/$CA_SIGN_SSL_CERT_REQUEST_FILENAME"
  rm -f "certificates/ssl_cert/$project_name/sign_request/$SIGNED_DOMAINS_FILENAME"
  rm -f "certificates/ssl_cert/$project_name/$SSL_PUBLIC_KEY_FILENAME"
  rm -f "certificates/merged/$project_name/$MERGED_CA_SSL_CERT_FILENAME"
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
  openssl genrsa -out "certificates/ssl_cert/$project_name/$ssl_private_key_filename" 4096 >>/dev/null 2>&1

  # Create a Certificate Signing Request (CSR)
  openssl req -new -sha256 -subj "/CN=yourcn" -key "certificates/ssl_cert/$project_name/$ssl_private_key_filename" -out "certificates/ssl_cert/$project_name/sign_request/$ca_sign_ssl_cert_request_filename" >>/dev/null 2>&1

  # Create a `extfile` with all the alternative names
  # TODO: silence.
  echo "subjectAltName=$domains" >>"certificates/ssl_cert/$project_name/sign_request/$signed_domains_filename"

  # Create the public SSL certificate.
  openssl x509 -passin file:$TEMP_SSL_PWD_FILENAME -req -sha256 -days 365 -in "certificates/ssl_cert/$project_name/sign_request/$ca_sign_ssl_cert_request_filename" -CA "certificates/root/$ca_public_key_filename" -CAkey "certificates/root/$ca_private_key_filename" -out "certificates/ssl_cert/$project_name/$ssl_public_key_filename" -extfile "certificates/ssl_cert/$project_name/sign_request/$signed_domains_filename" -CAcreateserial >>/dev/null 2>&1
}

verify_certificates() {
  local ca_public_key_filename="$1"
  local ssl_public_key_filename="$2"
  # TODO: raise error if verification is not successful.
  openssl verify -CAfile "certificates/root/$ca_public_key_filename" -verbose "certificates/ssl_cert/$project_name/$ssl_public_key_filename" >>/dev/null 2>&1
}

merge_ca_and_ssl_certs() {
  local project_name="$1"
  local ssl_public_key_filename="$2"
  local ca_public_key_filename="$3"
  local merged_ca_ssl_cert_filename="$4"

  cat "certificates/ssl_cert/$project_name/$ssl_public_key_filename" >"certificates/merged/$project_name/$merged_ca_ssl_cert_filename"
  cat "certificates/root/$ca_public_key_filename" >>"certificates/merged/$project_name/$merged_ca_ssl_cert_filename"
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
