#!/bin/bash

# Globals are loaded using an import, hence, they do not need to be exported.
# shellcheck disable=SC2034
TOR_SERVICE_DIR=/var/lib/tor
TORRC_FILEPATH=/etc/tor/torrc
TOR_LOG_FILEPATH="starting_tor_log.txt"
DEFAULT_HIDDENSERVICE_SSL_PORT=443
DEFAULT_LOCAL_PROJECT_PORT=81
TORRC_FILEPATH=/etc/tor/torrc
TOR_LOG_FILEPATH="tor_log.txt"
