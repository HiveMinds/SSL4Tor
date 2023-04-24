#!./test/libs/bats/bin/bats
# Requires internet connection.

load '../../../test/libs/bats-support/load'
load '../../../test/libs/bats-assert/load'

source src/ssl_certs/add_public_private_ssl_cert_to_service/verify_ssl_certs.sh

@test "src/ssl_certs/add_public_private_ssl_cert_to_service.sh, function is_alphanumeric: functions confirms if alphanumeric." {

  # Run function that is tested.
  run is_alphanumeric "abc02abz9"

  # Verify result is as expected.
  assert_output "FOUND"
}

@test "src/ssl_certs/add_public_private_ssl_cert_to_service.sh, function is_alphanumeric: functions confirms if non-alphanumeric." {

  # Run function that is tested.
  run is_alphanumeric "ab.c02abz9_"

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

@test "src/ssl_certs/add_public_private_ssl_cert_to_service.sh, function assert_is_alphanumeric: functions confirms if alphanumeric." {

  # Run function that is tested.
  run assert_is_alphanumeric "abc02abz9"

  # Verify result is as expected.
  assert_output ""
}

@test "src/ssl_certs/add_public_private_ssl_cert_to_service.sh, function assert_is_alphanumeric: functions confirms if non-alphanumeric." {
  local test_input="ab.c02abz9_"

  # Run function that is tested.
  run assert_is_alphanumeric "$test_input"
  assert_failure

  # Verify result is as expected.
  assert_output "Error, $test_input is not purely alphanumeric."

}
