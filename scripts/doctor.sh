#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

LOG_FILE="${LOG_DIR}/doctor-$(timestamp).log"

{
  log "Running Otsaria Reader build doctor"
  print_environment

  require_command xcodebuild
  require_command xcrun

  [ -d "${PROJECT_PATH}" ] || fail "Xcode project not found at ${PROJECT_PATH}"

  log "Listing project schemes"
  xcodebuild -list -project "${PROJECT_PATH}"

  log "Checking iOS SDK paths"
  xcrun --sdk iphoneos --show-sdk-path
  xcrun --sdk iphonesimulator --show-sdk-path

  log "Relevant build environment variables"
  printf 'XCODE_DEVELOPMENT_TEAM=%s\n' "${XCODE_DEVELOPMENT_TEAM:-}"
  printf 'XCODE_BUNDLE_ID=%s\n' "${XCODE_BUNDLE_ID:-}"
  printf 'EXPORT_OPTIONS_PLIST=%s\n' "${EXPORT_OPTIONS_PLIST:-}"
  printf 'ARCHIVE_PATH=%s\n' "${ARCHIVE_PATH:-}"

  log "Doctor completed"
} 2>&1 | tee "${LOG_FILE}"
