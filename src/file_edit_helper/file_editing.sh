#!/bin/bash
append_lines_if_not_found() {
  local first_line=$1
  local second_line=$2
  local rel_filepath=$3

  local has_block
  has_block=$(has_two_consecutive_lines "$first_line" "$second_line" "$rel_filepath")

  if [ "$has_block" == "NOTFOUND" ]; then
    echo "$first_line" | sudo tee -a "$rel_filepath"
    echo "$second_line" | sudo tee -a "$rel_filepath"
  fi
}

# Ensure the SSH service is contained in the tor configuration.
has_two_consecutive_lines() {
  local first_line=$1
  local second_line=$2
  local rel_filepath=$3

  if [ "$(file_contains_string "$first_line" "$rel_filepath")" == "FOUND" ]; then
    if [ "$(file_contains_string "$second_line" "$rel_filepath")" == "FOUND" ]; then
      # get line_nr first_line
      local first_line_line_nr
      first_line_line_nr="$(get_line_nr "$first_line" "$rel_filepath")"

      # get next line number
      local next_line_number
      next_line_number=$((first_line_line_nr + 1))

      # get next line
      local next_line
      next_line=$(get_line_by_nr "$next_line_number" "$rel_filepath")

      # verify next line equals the second line
      if [ "$next_line" == "$second_line" ]; then
        echo "FOUND"
      else
        echo "NOTFOUND"
      fi
    fi
  else
    echo "NOTFOUND"
  fi
}

verify_has_two_consecutive_lines() {
  local torrc_line_1="$1"
  local torrc_line_2="$2"
  local torrc_filepath="$3"

  local found_lines
  found_lines="$(has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$torrc_filepath")"
  if [ "$found_lines" != "FOUND" ]; then
    printf "==========================\\n"
    red_msg "Error, did not found expected two lines:"
    red_msg "$torrc_line_1"
    red_msg "$torrc_line_2"
    red_msg "in:"
    red_msg "$torrc_filepath"
    printf "==========================\\n\\n"
    exit 3 # TODO: update exit status.
  fi
}

#######################################
#
# Local variables:
#
# Globals:
#  None.
# Arguments:
#
# Returns:
#  0 if
#  7 if
# Outputs:
#  None.
#######################################
# Structure:Parsing
# allows a string with spaces, hence allows a line
file_contains_string() {
  STRING=$1
  relative_filepath=$2

  if grep -q "$STRING" "$relative_filepath"; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

#######################################
#
# Local variables:
#
# Globals:
#  None.
# Arguments:
#
# Returns:
#  0 if
#  7 if
# Outputs:
#  None.

#######################################
# Structure:Parsing
get_line_nr() {
  #eval STRING="$1"
  local string="$1"
  relative_filepath=$2
  local line_nr
  line_nr="$(grep -n "$string" "$relative_filepath" | head -n 1 | cut -d: -f1)"
  echo "$line_nr"
}

#######################################
#
# Local variables:
#
# Globals:
#  None.
# Arguments:
#
# Returns:
#  0 if
#  7 if
# Outputs:
#  None.

#######################################
# Structure:Parsing
get_line_by_nr() {
  number=$1
  relative_filepath=$2
  #read -p "number=$number"
  #read -p "relative_filepath=$relative_filepath"
  the_line=$(sed "${number}q;d" "$relative_filepath")
  echo "$the_line"
}
