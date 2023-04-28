#!/bin/bash

source src/GLOBAL_VARS.sh
source src/arg_parser/arg_parser.sh
source src/arg_parser/helper.sh
source src/arg_parser/parsing.sh
source src/arg_parser/process_args.sh
source src/arg_parser/print_usage.sh
source src/arg_parser/arg_verification.sh
source src/file_edit_helper/file_editing.sh
source src/firefox_version/firefox_version.sh
source src/helper.sh
source src/helper_parsing.sh
source src/installation/install_apt.sh
source src/installation/install_pip.sh
source src/installation/install_prerequisites.sh
source src/logging/cli_logging.sh
source src/onion_domain/delete_onion_domain.sh
source src/onion_domain/make_onion_domain.sh
source src/onion_domain/onion_domain_exists.sh
source src/record_cli.sh
source src/setup_ssh/client/ssh_client_setup.sh
source src/setup_ssh/server/ssh_server_setup.sh
source src/setup_ssh/ssh_status.sh
source src/setup_ssh/get_root_ca.sh
source src/setup_ssh/setup_ssh_public_private_key_access.sh
source src/ssl_certs/add_ssl_certs_to_service/add_to_gitlab.sh
source src/ssl_certs/add_ssl_certs_to_service/verify_ssl_certs.sh
source src/ssl_certs/add_root_ca_as_trusted/to_ubuntu.sh
source src/ssl_certs/ssl_certs_exist.sh
source src/ssl_certs/make_ssl_project_certs.sh
source src/ssl_certs/make_ssl_root_certs.sh
source src/tor_status/create_tor_connection.sh
source src/tor_status/tor_status.sh
source src/tor_status/verify_https_onion_is_available.sh
source src/uninstallation/uninstall_apt.sh
source src/verification/assert_exists.sh
source src/verification/assert_not_exists.sh
source src/website/run_dash_in_background.sh

# Get application name/dir from CLI.

# Ensure tor domain is created in "application" dir.

# Ensure tor was running in the background to create the onion domain.

# Verify the onion domain is reachable.

# Get the onion domain.

# Call the function that generates the SSL certs.

# Copy the certs into the relevant directories.

# Verify the https works.

# print the usage if no arguments are given
[ $# -eq 0 ] && {
  print_usage
  exit 1
}
parse_args "$@"
