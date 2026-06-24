#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

CONFIGURATION="${CONFIGURATION:-Release}"
DESTINATION="${DESTINATION:-generic/platform=iOS}"
LOG_FILE="${LOG_DIR}/unsigned-ipa-${CONFIGURATION}-$(timestamp).log"
IPA_DIR="${OUTPUT_DIR}/unsigned-ipa"
IPA_NAME="${IPA_NAME:-OtsariaReader-unsigned.ipa}"
IPA_PATH="${IPA_DIR}/${IPA_NAME}"
PAYLOAD_DIR="${IPA_DIR}/Payload"

require_command xcodebuild
require_command zip
[ -d "${PROJECT_PATH}" ] || fail "Xcode project not found at ${PROJECT_PATH}"

print_environment
log "Building unsigned device app for IPA packaging"
log "Destination: ${DESTINATION}"

run_xcodebuild_logged "${LOG_FILE}" \
  xcodebuild \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY= \
  clean build

PRODUCTS_DIR="${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}-iphoneos"
APP_PATH="${PRODUCTS_DIR}/OtsariaReader.app"
[ -d "${APP_PATH}" ] || fail "Built app was not found at ${APP_PATH}"

rm -rf "${IPA_DIR}"
mkdir -p "${PAYLOAD_DIR}"
cp -R "${APP_PATH}" "${PAYLOAD_DIR}/"

(
  cd "${IPA_DIR}"
  zip -qry "${IPA_NAME}" Payload
)

[ -f "${IPA_PATH}" ] || fail "IPA was not created at ${IPA_PATH}"

log "Unsigned IPA created"
log "IPA: ${IPA_PATH}"
log "Full log: ${LOG_FILE}"

cat > "${IPA_DIR}/README.txt" <<EOF
This IPA is unsigned and is produced by GitHub Actions for download/testing artifacts.
It will not install on a normal iPhone or iPad unless it is signed or re-signed with a valid Apple certificate/provisioning profile.
For an installable IPA, run scripts/archive.sh and scripts/export-ipa.sh on a Mac with Apple Developer signing configured.
EOF
