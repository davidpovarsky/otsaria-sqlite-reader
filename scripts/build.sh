#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

CONFIGURATION="${CONFIGURATION:-Debug}"
DESTINATION="${DESTINATION:-generic/platform=iOS Simulator}"
LOG_FILE="${LOG_DIR}/build-${CONFIGURATION}-$(timestamp).log"

require_command xcodebuild
[ -d "${PROJECT_PATH}" ] || fail "Xcode project not found at ${PROJECT_PATH}"

print_environment
log "Building for destination: ${DESTINATION}"

run_xcodebuild_logged "${LOG_FILE}" \
  xcodebuild \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  CODE_SIGNING_ALLOWED=NO \
  clean build

log "Build succeeded"
log "Full log: ${LOG_FILE}"
