#!/bin/bash

source src/arg_parser/arg_parser.sh
source src/arg_parser/process_args.sh
source src/arg_parser/print_usage.sh
source src/arg_parser/arg_verification.sh
source src/generate_onion_domain/generate_onion_domain.sh
source src/installation/install_apt.sh
source src/uninstallation/uninstall_apt.sh
source src/logging/cli_logging.sh
source src/verification/manual_asserts.sh
source src/GLOBAL_VARS.sh
source src/file_edit_helper/file_editing.sh

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

say_hello() {
  echo "Done parsing args. Hello world."
}
say_hello
