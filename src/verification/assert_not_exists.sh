#!/bin/bash
#######################################
# Verifies a file exists, throws error otherwise.
# Local variables:
#  filepath
# Globals:
#  None.
# Arguments:
#  Relative filepath of file whose existence is verified.
# Returns:
#  0 If file was found.
#  29 If the file was not found.
# Outputs:
#  Nothing
#######################################
manual_assert_file_not_exists() {
  local filepath="$1"
  local use_sudo="$2"

  if [[ "$use_sudo" == "true" ]]; then
    if sudo test -f "$filepath"; then
      echo "The file: $filepath still exists, even though"
      echo " one would expect it does not exist."
      exit 31
    fi
  elif test -f "$filepath"; then
    echo "The file: $filepath does still exists, even though one would expect"
    echo " it does not exist."
    exit 31
  fi
}

#######################################
# Verifies a directory exists, throws error otherwise.
# Local variables:
#  dirpath
# Globals:
#  None.
# Arguments:
#  Relative folderpath of folder whose existence is verified.
# Returns:
#  0 If folder was found.
#  31 If the folder was not found.
# Outputs:
#  Nothing
#######################################
manual_assert_dir_not_exists() {
  local dirpath="$1"
  local use_sudo="$2"
  if [[ "$use_sudo" == "true" ]]; then
    if sudo test -d "$dirpath"; then
      echo "The dir: $dirpath still exists, even though"
      echo " one would expect it does not exist."
      exit 31
    fi
  elif test -d "$dirpath"; then
    echo "The dir: $dirpath does still exists, even though one would expect"
    echo " it does not exist."
    exit 31
  fi
}
