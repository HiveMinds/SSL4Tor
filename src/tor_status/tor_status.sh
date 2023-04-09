#!/bin/bash
get_tor_status() {
  local tor_status
  tor_status=$(curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations | xargs)
  echo "$tor_status"
}

tor_is_connected() {
  local tor_status_outside
  tor_status_outside=$(get_tor_status)
  # Reconnect tor if the system is disconnected.
  if [[ "$tor_status_outside" != *"Congratulations"* ]]; then
    echo "NOTFOUND"
  elif [[ "$tor_status_outside" == *"Congratulations"* ]]; then
    echo "FOUND"
  fi
}
