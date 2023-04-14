#!/bin/bash

run_dash_in_background() {
  local local_project_port="$1"
  local project_name="$2"

  terminate_process_on_port "$local_project_port"

  python3 src/website/mwe_dash.py --port "$local_project_port" --project-name "$project_name" --use-https
}

port_is_occupied() {
  local local_project_port="$1"
  local output
  output="$(sudo lsof -i:"$local_project_port")"

  if [[ "$output" != "" ]]; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

assert_port_is_occupied() {
  local local_project_port="$1"

  if [[ "$(port_is_occupied "$local_project_port")" != "FOUND" ]]; then
    echo "Error, port:$local_project_port is not occupied:$(sudo lsof -i:"$local_project_port")"
    exit 6
  fi
}

assert_port_is_free() {
  local local_project_port="$1"

  if [[ "$(port_is_occupied "$local_project_port")" != "NOTFOUND" ]]; then
    echo "Error, port:$local_project_port is occupied:$(sudo lsof -i:"$local_project_port")"
    exit 6
  fi
}
terminate_process_on_port() {
  local local_project_port="$1"

  local pids
  pids="$(sudo lsof -t -i:"$local_project_port")"
  read -p "pids=$pids-ENDWITHOUTSPACE"
  local first_pid
  first_pid=${pids%$'\n'*}
  read -p "first_pid=$first_pid-ENDWITHOUTSPACE"

  # sudo kill -9 "$(lsof -t -i:"$local_project_port")"
  sudo kill -9 "$(lsof -t -i:"$first_pid")"
  assert_port_is_free "$local_project_port"
}
