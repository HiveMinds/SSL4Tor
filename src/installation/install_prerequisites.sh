#!/bin/bash
install_apt_prerequisites() {
  ensure_apt_pkg "curl" 0
  # TODO: determine why this does not detect the pip installation.
  # ensure_apt_pkg "pip" 0
  sudo apt --assume-yes install pip >>/dev/null 2>&1
  ensure_apt_pkg "tor" 0
  ensure_apt_pkg "jq" 0
  ensure_apt_pkg "net-tools" 0
  ensure_apt_pkg "httping" 0
  ensure_apt_pkg "ca-certificates" 0
  ensure_apt_pkg "openssh-server" 0
  ensure_pip_pkg "dash" 0
  ensure_pip_pkg "pandas" 1

}
