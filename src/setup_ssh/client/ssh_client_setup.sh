#!/bin/bash

ssh_client_prerequisites() {
  # apt_remove "openssh-server" 0
  ensure_apt_pkg "openssh-server" 0
  ensure_apt_pkg "curl" 0
  ensure_apt_pkg "net-tools" 0
  ensure_apt_pkg "openssh-client" 0
  ensure_apt_pkg "torsocks" 0
  ensure_apt_pkg "tor" 1
  # TODO: determine why this throws error and why it is not in apt list ssh-co*
  #ensure_apt_pkg "ssh-copy-id" 1

  # THIS IS ESSENTIAL IF YOU GET:
  # [syscall] Unsupported syscall number 39.
  # Source: Comment in: https://askubuntu.com/q/1264335
  # NO SUDO REQUIRED.
  chmod g-w ~/.ssh/config >>/dev/null 2>&1

  # TODO: Ensure tor is started in the background.
  start_tor_in_background
}
