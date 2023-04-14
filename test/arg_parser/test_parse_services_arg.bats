#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

source src/arg_parser/helper.sh

@test "/src/arg_parser/parsing.sh, function assert_services_are_valid functions with 1 project" {
  # Specify input data for test.
  local test_input="1234:some_name:5678"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run assert_services_are_valid "$test_input"

  # Verify result is as expected.
  assert_output ""
}

@test "/src/arg_parser/parsing.sh, function assert_services_are_valid functions with 2 projects" {
  # Specify input data for test.
  local test_input="1234:some_name:5678/910:some_other_name:1112"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run assert_services_are_valid "$test_input"

  # Verify result is as expected.
  assert_output ""
}
