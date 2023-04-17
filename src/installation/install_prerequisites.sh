#!/bin/bash
install_apt_prerequisites() {
  ensure_apt_pkg "curl" 1
  # TODO: determine why this does not detect the pip installation.
  # ensure_apt_pkg "pip" 1
  sudo apt --assume-yes install pip >>/dev/null 2>&1
  ensure_apt_pkg "tor" 1
  ensure_apt_pkg "net-tools" 1
  ensure_apt_pkg "httping" 1
  ensure_apt_pkg "ca-certificates" 1
  ensure_apt_pkg "openssh-server" 1
  ensure_pip_pkg "dash" 1
  ensure_pip_pkg "pandas" 1

}
