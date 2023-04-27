#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "/src/arg_parser/helper.sh, function check_project_name: functions with valid input:bikes." {
  # Specify input data for test.
  local test_input="bikes"
  local supported_projects="bikes/flowers/planes"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run check_project_name "$test_input" "$supported_projects"

  # Verify result is as expected.
  assert_output "FOUND"
}

@test "/src/arg_parser/helper.sh, function check_project_name: functions with valid input:flowers." {
  # Specify input data for test.
  local test_input="bikes"
  local supported_projects="bikes/flowers/planes"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run check_project_name "$test_input" "$supported_projects"

  # Verify result is as expected.
  assert_output "FOUND"
}

@test "/src/arg_parser/helper.sh, function check_project_name: functions with valid input:planes." {
  # Specify input data for test.
  local test_input="bikes"
  local supported_projects="bikes/flowers/planes"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run check_project_name "$test_input" "$supported_projects"

  # Verify result is as expected.
  assert_output "FOUND"
}

@test "/src/arg_parser/helper.sh, function check_project_name: functions with invalid input:empty." {
  # Specify input data for test.
  local test_input=""
  local supported_projects="bikes/flowers/planes"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run check_project_name "$test_input" "$supported_projects"

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

@test "/src/arg_parser/helper.sh, function check_project_name: functions with invalid input:something." {
  # Specify input data for test.
  local test_input="something"
  local supported_projects="bikes/flowers/planes"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run check_project_name "$test_input" "$supported_projects"

  # Verify result is as expected.
  assert_output "NOTFOUND"
}
