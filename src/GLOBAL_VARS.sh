#!/bin/bash

# Globals are loaded using an import, hence, they do not need to be exported.
# shellcheck disable=SC2034
TOR_SERVICE_DIR=/var/lib/tor
TORRC_FILEPATH=/etc/tor/torrc
TOR_LOG_FILEPATH="starting_tor_log.txt"
PUBLIC_PORT_TO_ACCESS_ONION_SITE_WITH_SSL=443
PUBLIC_PORT_TO_ACCESS_ONION_SITE_WITHOUT_SSL=80
DEFAULT_LOCAL_PROJECT_PORT=8050
TORRC_FILEPATH=/etc/tor/torrc
TOR_LOG_FILEPATH="tor_log.txt"
