#!/bin/bash

ssh_client_prerequisites() {
  # Install ssh
  #sudo apt install openssh-client

  # Connect to server

  apt_remove "openssh-server" 1
  ensure_apt_pkg "openssh-client" 1
  ensure_apt_pkg "torsocks" 1

  # THIS IS ESSENTIAL IF YOU GET:
  # [syscall] Unsupported syscall number 39.
  # Source: Comment in: https://askubuntu.com/q/1264335
  # NO SUDO REQUIRED.
  chmod g-w ~/.ssh/config

  # SSH into the server:
  torsocks ssh server_ubuntu_username@ssh_onion_domain.onion
}
