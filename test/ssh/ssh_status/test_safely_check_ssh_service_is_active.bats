#!./test/libs/bats/bin/bats
# Requires internet connection.

load '../../libs/bats-support/load'
load '../../libs/bats-assert/load'

source src/setup_ssh/ssh_status.sh
source src/setup_ssh/server/ssh_server_setup.sh
source src/installation/install_apt.sh
source src/uninstallation/uninstall_apt.sh
source src/logging/cli_logging.sh
source src/helper_parsing.sh

teardown() {
  # By default, keep ssh enabled and active.
  apt_remove "openssh-server" 1
  ensure_apt_pkg "openssh-server" 1

  sudo systemctl enable --now ssh
}

@test "src/setup_ssh/ssh_status.sh, function safely_check_ssh_service_is_active: functions if ssh service available and running." {
  # Ensure openssh-server is installed.
  apt_remove "openssh-server" 1
  ensure_apt_pkg "openssh-server" 1

  sudo systemctl enable --now ssh

  # Run function that is tested.
  run safely_check_ssh_service_is_active

  # Verify result is as expected.
  assert_output "FOUND"
}

@test "src/setup_ssh/ssh_status.sh, function safely_check_ssh_service_is_active: functions if ssh service is not available." {
  # Ensure openssh-server is installed. That implies ssh should be running.
  apt_remove "openssh-server" 1

  #safely_deactivate_ssh_service
  sudo systemctl stop ssh >>/dev/null 2>&1

  # Run function that is tested.
  run safely_check_ssh_service_is_active

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

@test "src/setup_ssh/ssh_status.sh, function safely_check_ssh_service_is_active: functions if ssh service available but disabled." {
  # Ensure openssh-server is installed.
  apt_remove "openssh-server" 1
  ensure_apt_pkg "openssh-server" 1

  sudo systemctl stop ssh

  # Run function that is tested.
  run safely_check_ssh_service_is_active

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

# TODO: write test for: ssh is available, enabled but inactive.
