#!/bin/bash
install_apt_prerequisites() {
  ensure_apt_pkg "curl" 1
  ensure_apt_pkg "tor" 1
  ensure_apt_pkg "net-tools" 1
  ensure_apt_pkg "httping" 1
  ensure_apt_pkg "ca-certificates" 1
}
