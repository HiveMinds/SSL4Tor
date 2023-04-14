#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "/src/arg_parser/helper.sh, function project_name_contains_only_letters_and_underscores: functions with valid input." {
  # Specify input data for test.
  local test_input="abcdefghlaqwoeirupqpoizsxcvznxcvmasdfijasdfpiu"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run project_name_contains_only_letters_and_underscores "$test_input"

  # Verify result is as expected.
  assert_output "FOUND"
}

@test "/src/arg_parser/helper.sh, function project_name_contains_only_letters_and_underscores: catches invalid input." {
  # Specify input data for test.
  local test_input="a2bcdefghlaqwoeirupqpoizsxcvznxcvmasdfijasdfpiu"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run project_name_contains_only_letters_and_underscores "$test_input"

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

@test "/src/arg_parser/helper.sh, function project_name_contains_only_letters_and_underscores: catches empty input." {
  # Specify input data for test.
  local test_input=""

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run project_name_contains_only_letters_and_underscores "$test_input"

  # Verify result is as expected.
  assert_output "NOTFOUND"
}

@test "/src/arg_parser/helper.sh, function assert_project_name_contains_only_letters_and_underscores: functions with valid input." {
  # Specify input data for test.
  local test_input="abcdefghlaqwoeirupqpoizsxcvznxcvmasdfijasdfpiu"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run assert_project_name_contains_only_letters_and_underscores "$test_input"

  # Verify result is as expected.
  assert_output ""
}

@test "/src/arg_parser/helper.sh, function assert_project_name_contains_only_letters_and_underscores: functions with valid input and underscores." {
  # Specify input data for test.
  local test_input="abcdefghlaqwoeirupqpoizsxcvznxcvm_asdfijasdfpiu_"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run assert_project_name_contains_only_letters_and_underscores "$test_input"

  # Verify result is as expected.
  assert_output ""
}

@test "/src/arg_parser/helper.sh, function assert_project_name_contains_only_letters_and_underscores: catches invalid input." {
  # Specify input data for test.
  local test_input="a2bcdefghlaqwoeirupqpoizsxcvznxcvmasdfijasdfpiu"

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run assert_project_name_contains_only_letters_and_underscores "$test_input"
  assert_failure

  # Verify result is as expected.
  assert_output "Error, project_name:$test_input contains non-letter characters (that aren't underscores _)."
}

@test "/src/arg_parser/helper.sh, function assert_project_name_contains_only_letters_and_underscores: catches empty input." {
  # Specify input data for test.
  local test_input=""

  # Load the function that is to be tested.
  source src/arg_parser/helper.sh

  # Run function that is tested.
  run assert_project_name_contains_only_letters_and_underscores "$test_input"
  assert_failure

  # Verify result is as expected.
  assert_output "Error, project_name:$test_input contains non-letter characters (that aren't underscores _)."
}
