#!/bin/bash

ssh_client_prerequisites() {
  apt_remove "openssh-server" 1
  ensure_apt_pkg "openssh-client" 1
  ensure_apt_pkg "torsocks" 1
  ensure_apt_pkg "tor" 1

  # THIS IS ESSENTIAL IF YOU GET:
  # [syscall] Unsupported syscall number 39.
  # Source: Comment in: https://askubuntu.com/q/1264335
  # NO SUDO REQUIRED.
  chmod g-w ~/.ssh/config

  # TODO: Ensure tor is started in the background.

  # SSH into the server:
  echo "You are ready to ssh into your onion server. To get the command to ssh"
  echo "into your server. Open the server, set up the onion domain (see README)"
  echo "and, run (in server):"
  echo "./src/main.sh --1-domain-1-service --services 22:ssh:22 --get-onion-domain"
  echo "Which should return something like:"
  echo "torsocks ssh <server_ubuntu_username>@<ssh_onion_hash>.onion"
}
