#!/usr/bin/env bash
# Bakes the self-hosted server, its public key and the app name into the sources.
# Usage: APP_NAME=MeuSuporte RENDEZVOUS_SERVER=1.2.3.4 RS_PUB_KEY=xxx bash custom-client/apply.sh
set -euo pipefail

: "${APP_NAME:?APP_NAME is required}"
: "${RENDEZVOUS_SERVER:?RENDEZVOUS_SERVER is required}"
: "${RS_PUB_KEY:?RS_PUB_KEY is required}"
APP_DESCRIPTION="${APP_DESCRIPTION:-$APP_NAME}"

if [[ ! "$APP_NAME" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "APP_NAME must contain only letters, digits, '-' or '_' (it is used in paths and service names)" >&2
  exit 1
fi

cd "$(dirname "$0")/.."
cfg=libs/hbb_common/src/config.rs

replace() {
  local file=$1 from=$2 to=$3
  if ! grep -qF -- "$from" "$file"; then
    echo "pattern not found in $file: $from" >&2
    exit 1
  fi
  FROM="$from" TO="$to" perl -0pi -e 's/\Q$ENV{FROM}\E/$ENV{TO}/g' "$file"
}

replace "$cfg" 'pub const RENDEZVOUS_SERVERS: &[&str] = &["rs-ny.rustdesk.com"];' \
  "pub const RENDEZVOUS_SERVERS: &[&str] = &[\"$RENDEZVOUS_SERVER\"];"
replace "$cfg" 'pub const RS_PUB_KEY: &str = "OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=";' \
  "pub const RS_PUB_KEY: &str = \"$RS_PUB_KEY\";"
replace "$cfg" 'RwLock::new("RustDesk".to_owned())' "RwLock::new(\"$APP_NAME\".to_owned())"

replace flutter/windows/runner/Runner.rc '"RustDesk Remote Desktop"' "\"$APP_DESCRIPTION\""
replace flutter/windows/runner/Runner.rc 'VALUE "ProductName", "RustDesk"' "VALUE \"ProductName\", \"$APP_NAME\""
replace flutter/windows/runner/main.cpp 'std::wstring app_name = L"RustDesk";' "std::wstring app_name = L\"$APP_NAME\";"
replace Cargo.toml 'ProductName = "RustDesk"' "ProductName = \"$APP_NAME\""
replace Cargo.toml 'FileDescription = "RustDesk Remote Desktop"' "FileDescription = \"$APP_DESCRIPTION\""

if [[ -f custom-client/icon.ico ]]; then
  cp custom-client/icon.ico res/icon.ico
  cp custom-client/icon.ico flutter/windows/runner/resources/app_icon.ico
fi

echo "Custom client applied: $APP_NAME -> $RENDEZVOUS_SERVER"
