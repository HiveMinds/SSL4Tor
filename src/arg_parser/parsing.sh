#!/bin/bash

get_nr_of_services() {
  local services="$1"
  IFS='/' read -r -a project_descriptions <<<"$services"
  echo "${#project_descriptions[@]}"
}

assert_services_are_valid() {
  local services="$1"
  local nr_of_services
  nr_of_services=$(get_nr_of_services "$services")
  start=0
  for ((project_nr = start; project_nr < nr_of_services; project_nr++)); do
    output=$(get_project_property_by_index "$services" "$project_nr" "local_port" 2>&1) || echo "$output"
    output=$(get_project_property_by_index "$services" "$project_nr" "project_name" 2>&1) || echo "$output"
    output=$(get_project_property_by_index "$services" "$project_nr" "external_port" 2>&1) || echo "$output"
  done

}

get_project_property_by_index() {
  local services="$1"
  local project_nr="$2"
  local property="$3"
  IFS='/' read -r -a project_descriptions <<<"$services"

  for index in "${!project_descriptions[@]}"; do
    if [ "$index" -eq "$project_nr" ]; then
      if [[ "$property" == "local_port" ]]; then
        get_port_from_project_description "0" "${project_descriptions[index]}"
      elif [[ "$property" == "project_name" ]]; then
        get_project_name_from_project_description "${project_descriptions[index]}"
      elif [[ "$property" == "external_port" ]]; then
        get_port_from_project_description "2" "${project_descriptions[index]}"
      else
        echo "property:$property cannot be retrieved currently."
      fi
    fi
  done
}

# Project description has format: <local_port>:<project_name>:<external_port>
# This is then separated on : yielding the local port at description position
# 0, and the externa port at description position 2.
# TODO: assert description_position is in [0,2].
get_port_from_project_description() {
  local description_position="$1"
  local project_description="$2"

  local IFS
  IFS=':' read -r -a project_array <<<"$project_description"
  for index in "${!project_array[@]}"; do
    # if [ "$index" -eq "$description_position" ]; then
    if [[ "$index" == "$description_position" ]]; then
      assert_port_is_numeric "${project_array[index]}"
      echo "${project_array[index]}"
    fi
  done
}

# Project description has format: <local_port>:<project_name>:<external_port>
# This is then separated on : yielding the project name at description
# position 1.
get_project_name_from_project_description() {
  local project_description="$1"

  local IFS
  IFS=':' read -r -a project_array <<<"$project_description"

  assert_project_name_contains_only_letters_and_underscores "${project_array[1]}"
  echo "${project_array[1]}"

}
