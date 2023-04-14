#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

source src/arg_parser/helper.sh

@test "/src/arg_parser/parsing.sh, function get_project_name_from_project_description functions with 1 project" {
  # Specify input data for test.
  local test_input="1234:some_name:5678"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run get_project_name_from_project_description "$test_input"

  # Verify result is as expected.
  assert_output some_name
}

@test "/src/arg_parser/parsing.sh, function get_project_name_from_project_description functions with 2 projects." {
  # Specify input data for test.
  local services="1234:some_name:5678/910:some_other_name:1112"
  local project_nr="0"
  local property="project_name"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run get_project_property_by_index "$services" "$project_nr" "$property"

  # Verify result is as expected.
  assert_output some_name

  # Run function that is tested.
  project_nr="1"
  run get_project_property_by_index "$services" "$project_nr" "$property"

  # Verify result is as expected.
  assert_output some_other_name
}

@test "/src/arg_parser/parsing.sh, function get_project_name_from_project_description catches error in 2nd project name." {
  # Specify input data for test.
  local services="""1234:some_name:5678/910(:some_ot-her_name:1112-"""
  local project_nr="0"
  local property="project_name"

  # Load the function that is to be tested.
  source src/arg_parser/parsing.sh

  # Run function that is tested.
  run get_project_property_by_index "$services" "$project_nr" "$property"

  # Verify result is as expected.
  assert_output "some_name"

  # Run function that is tested.
  project_nr="1"
  run get_project_property_by_index "$services" "$project_nr" "$property"
  assert_failure

  # Verify result is as expected.
  assert_output "Error, project_name:some_ot-her_name contains non-letter characters (that aren't underscores _)."
}
