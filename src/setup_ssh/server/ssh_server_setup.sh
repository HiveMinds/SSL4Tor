#!/bin/bash

ssh_server_prerequisites() {
  # Install ssh
  ensure_apt_pkg "openssh-server" 1

  safely_activate_ssh_service

  # TODO: Allow ssh through firewall.
  #sudo ufw allow ssh

  # Check ssh is allowed through firewall.
  #sudo ufw status

  # TODO: Then switch to client?
}

safely_activate_ssh_service() {

  # TODO: verify openssh-server is installed.

  if [[ "$(can_find_ssh_service)" == "FOUND" ]]; then
    sudo systemctl enable --now ssh

    # Assert ssh is activated.
    assert_ssh_service_is_available_enabled_and_active
  fi
  assert_ssh_service_is_available_enabled_and_active
}

safely_deactivate_ssh_service() {

  if [[ "$(can_find_ssh_service)" == "FOUND" ]]; then
    sudo systemctl stop ssh >>/dev/null 2>&1

    # Assert ssh is not activated.
    assert_ssh_service_is_not_available_enabled_and_active
  fi
}
