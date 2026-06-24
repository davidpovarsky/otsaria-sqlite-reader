#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

CONFIGURATION="${CONFIGURATION:-Release}"
ARCHIVE_PATH="${ARCHIVE_PATH:-${ARCHIVE_DIR}/OtsariaReader-$(timestamp).xcarchive}"
LOG_FILE="${LOG_DIR}/archive-${CONFIGURATION}-$(timestamp).log"

require_command xcodebuild
[ -d "${PROJECT_PATH}" ] || fail "Xcode project not found at ${PROJECT_PATH}"

SIGNING_SETTINGS=()
if [ -n "${XCODE_DEVELOPMENT_TEAM:-}" ]; then
  SIGNING_SETTINGS+=("DEVELOPMENT_TEAM=${XCODE_DEVELOPMENT_TEAM}")
fi
if [ -n "${XCODE_BUNDLE_ID:-}" ]; then
  SIGNING_SETTINGS+=("PRODUCT_BUNDLE_IDENTIFIER=${XCODE_BUNDLE_ID}")
fi

print_environment
log "Archiving iOS app"
log "Archive path: ${ARCHIVE_PATH}"

run_xcodebuild_logged "${LOG_FILE}" \
  xcodebuild \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -destination "generic/platform=iOS" \
  -archivePath "${ARCHIVE_PATH}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  -allowProvisioningUpdates \
  "${SIGNING_SETTINGS[@]}" \
  clean archive

printf '%s\n' "${ARCHIVE_PATH}" > "${LATEST_ARCHIVE_FILE}"
log "Archive succeeded"
log "Archive path written to: ${LATEST_ARCHIVE_FILE}"
log "Full log: ${LOG_FILE}"
