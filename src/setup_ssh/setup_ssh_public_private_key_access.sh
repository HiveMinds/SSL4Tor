#!/bin/bash

# By default ssh access happens through password. This is unsafe. Instead,
# Generate a private and public key on your client. Then send that public key
# to your server (the one with the onion domain). Then add that public key
# to the ssh-agent of/in the client.
#
# (Such that when the server sees your client trying to ssh access the server
# with the client private key, and the server asks the ssh-agent in your
#client: "solve this prime with your private key"), the ssh-agent in your
# client knows where to find the private key.

CLIENT_SSH_KEY_NAME="client_ssh"
CLIENT_SSH_DIR="/home/$(whoami)/.ssh/"

setup_passwordless_ssh_access_to_server() {
  local server_username="$1"
  local server_onion_domain="$2"

  create_private_public_ssh_key_on_client

  add_public_client_key_to_ssh_agent_of_client

  export_public_client_key_into_server "$server_username" "$server_onion_domain"
}

create_private_public_ssh_key_on_client() {
  # Delete ssh keys if they already exist.
  rm -f "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME"
  rm -f "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME.pub"

  ssh-keygen -b 4096 -t rsa -f "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME" -q -N "" >>/dev/null 2>&1

  manual_assert_file_exists "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME"
}

# This makes sure your client can show the server it should get access.
add_public_client_key_to_ssh_agent_of_client() {

  # Assert the private and public ssh key are created on client.
  manual_assert_file_exists "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME"

  # Start the ssh-agent in the background and prepare it for receiving
  # your client's ssh private key.
  eval "$(ssh-agent -s)"

  # Add your client's ssh private key to the client ssh-agent.
  ssh-add "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME" >>/dev/null 2>&1

}

export_public_client_key_into_server() {
  local server_username="$1"
  local server_onion_domain="$2"

  assert_is_non_empty_string "${server_username}"
  assert_is_non_empty_string "${server_onion_domain}"

  manual_assert_file_exists "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME"

  # TODO: Assert the private key is in the client ssh-agent.

  # Install the client public key into the server.
  torsocks ssh-copy-id -i "$CLIENT_SSH_DIR$CLIENT_SSH_KEY_NAME" "$server_username@$server_onion_domain"
}
