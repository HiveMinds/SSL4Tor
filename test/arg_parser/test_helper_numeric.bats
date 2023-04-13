#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "/src/arg_parser/helper.sh, function port_is_numeric: functions with valid input." {
  # Specify input data for test.
  local test_input="1234"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run port_is_numeric "$test_input"

  # Verify result is as expected.
  assert_output "FOUND"
}

@test "/src/arg_parser/helper.sh, function port_is_numeric: catches invalid input." {
  # Specify input data for test.
  local test_input="12a34"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run port_is_numeric "$test_input"

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

@test "/src/arg_parser/helper.sh, function port_is_numeric: catches empty input." {
  # Specify input data for test.
  local test_input=""

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run port_is_numeric "$test_input"

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

@test "/src/arg_parser/helper.sh, function assert_port_is_numeric: functions with valid input." {
  # Specify input data for test.
  local test_input="1234"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run assert_port_is_numeric "$test_input"

  # Verify result is as expected.
  assert_output ""
}

@test "/src/arg_parser/helper.sh, function assert_port_is_numeric: catches invalid input." {
  # Specify input data for test.
  local test_input="12a34"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run assert_port_is_numeric "$test_input"
  assert_failure

  # Verify result is as expected.
  assert_output "Error, port:$test_input is not numeric."
}

@test "/src/arg_parser/helper.sh, function assert_port_is_numeric: catches empty input." {
  # Specify input data for test.
  local test_input=""

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run assert_port_is_numeric "$test_input"
  assert_failure

  # Verify result is as expected.
  assert_output "Error, port:$test_input is not numeric."
}
