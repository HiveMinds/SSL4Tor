#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

source src/arg_parser/helper.sh

@test "/src/arg_parser/parsing.sh, function get_port_from_project_description functions with 1 project" {
  # Specify input data for test.
  local test_input="1234:some_name:5678"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run get_port_from_project_description "2" "$test_input"

  # Verify result is as expected.
  assert_output 5678
}

@test "/src/arg_parser/parsing.sh, function get_port_from_project_description functions with 2 projects." {
  # Specify input data for test.
  local services="1234:some_name:5678/910:some_other_name:1112"
  local project_nr="0"
  local property="external_port"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run get_project_property_by_index "$services" "$project_nr" "$property"

  # Verify result is as expected.
  assert_output 5678

  # Run function that is tested.
  project_nr="1"
  run get_project_property_by_index "$services" "$project_nr" "$property"

  # Verify result is as expected.
  assert_output 1112
}

@test "/src/arg_parser/parsing.sh, function get_port_from_project_description catches error in 2nd project name." {
  # Specify input data for test.
  local services="""1234:some_name:5678/910(:some_other_name:1112-"""
  local project_nr="0"
  local property="external_port"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run get_project_property_by_index "$services" "$project_nr" "$property"

  # Verify result is as expected.
  assert_output 5678

  # Run function that is tested.
  project_nr="1"
  run get_project_property_by_index "$services" "$project_nr" "$property"
  assert_failure

  # Verify result is as expected.
  assert_output "Error, port:1112- is not numeric."
}
