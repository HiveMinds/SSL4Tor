#!/bin/bash

install_cli_recording_to_gif_agg() {
  ensure_apt_pkg "curl" 1
  ensure_apt_pkg "cargo" 1

  # Install build requirements for agg cargo.
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup.rs
  chmod +x rustup.rs
  ./rustup.rs -y >>/dev/null 2>&1
  rm rustup.rs

  # Get the `agg` (asciinema .cast to .gif converter)
  folder="agg"
  url="https://github.com/asciinema/agg.git"
  git clone "${url}" "${folder}" 2>/dev/null

  # Build the converter software (if it was not already built).
  if test ! -d "$folder/target"; then
    cargo build -r --manifest-path "$folder"/Cargo.toml
  fi

  # Copy the executable to path such that you can call it from anywhere.
  sudo cp "$folder"/target/release/agg /usr/local/bin/

}

agg_is_installed() {
  local output_that_also_captures_error
  output_that_also_captures_error="$(agg --version 2>&1)"

  if [[ "$output_that_also_captures_error" == "agg 1."* ]]; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}

assert_agg_is_installed() {
  if [[ "$(agg_is_installed)" != "FOUND" ]]; then
    echo "Error, agg was not installed."
    exit 6
  fi
}

install_agg_if_not_installed() {
  if [[ "$(agg_is_installed)" != "FOUND" ]]; then
    install_cli_recording_to_gif_agg
  fi
  assert_agg_is_installed
}

install_cli_recorder_asciinema() {
  ensure_apt_pkg "asciinema" 1
}

record_cli() {
  local cli_record_filename="$1"

  install_cli_recorder_asciinema
  install_agg_if_not_installed

  # Condense all pauses/static frames into a 0.1 second timeframe.
  asciinema rec "$cli_record_filename".cast -i 1 --overwrite

  # To terminate the recording type:`exit` <enter>.
  agg "$cli_record_filename".cast "$cli_record_filename".gif

  manual_assert_file_exists "$cli_record_filename".gif
}
