#!/bin/bash
port_is_numeric() {
  local port_nr="$1"
  if [[ "$port_nr" =~ ^[0-9]+$ ]]; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi

}

assert_port_is_numeric() {
  local port_nr="$1"

  if [[ "$(port_is_numeric "$port_nr")" != "FOUND" ]]; then
    echo "Error, port:$port_nr is not numeric."
    exit 5
  fi
}

project_name_contains_only_letters_and_underscores() {
  local project_name="$1"

  # Remove all underscores
  project_name=${project_name//_/}

  # Verify it only contains lowercase letters (a to z).
  if [[ "$project_name" =~ ^[a-z]+$ ]]; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

assert_project_name_contains_only_letters_and_underscores() {
  local project_name="$1"

  if [[ "$(project_name_contains_only_letters_and_underscores "$project_name")" != "FOUND" ]]; then
    echo "Error, project_name:$project_name contains non-letter characters (that aren't underscores _)."
    exit 5
  fi
}

project_name_is_supported() {
  local project_name="$1"
  local supported_projects="$2"

  IFS='/' read -r -a supported_project_name_arr <<<"$supported_projects"

  for proj in "${supported_project_name_arr[@]}"; do
    if [[ "$proj" == "$project_name" ]]; then
      echo "FOUND"
      return 0
    fi
  done
  echo "NOTFOUND"
  return 1
}

assert_project_name_is_supported() {
  local project_name="$1"
  local supported_projects="$2"
  if [[ "$(project_name_is_supported "$project_name" "$supported_projects")" != "FOUND" ]]; then
    echo "Error, project_name:$project_name is not (yet) supported."
    exit 5
  fi
}
