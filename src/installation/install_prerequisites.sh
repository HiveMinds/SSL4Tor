#!/bin/bash
install_apt_prerequisites() {
  ensure_apt_pkg "curl" 1
  ensure_apt_pkg "pip" 1
  ensure_apt_pkg "tor" 1
  ensure_apt_pkg "net-tools" 1
  ensure_apt_pkg "httping" 1
  ensure_apt_pkg "ca-certificates" 1
  ensure_apt_pkg "openssh-server" 1
  ensure_pip_pkg "dash" 1
  ensure_pip_pkg "pandas" 1

}
