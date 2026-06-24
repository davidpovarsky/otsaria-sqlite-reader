#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

EXPORT_KIND="${1:-development}"
EXPORT_PATH="${EXPORT_PATH:-${OUTPUT_DIR}/ipa-$(timestamp)}"
LOG_FILE="${LOG_DIR}/export-ipa-${EXPORT_KIND}-$(timestamp).log"

require_command xcodebuild

case "${EXPORT_KIND}" in
  development)
    DEFAULT_EXPORT_OPTIONS="${ROOT_DIR}/ExportOptions/Development.plist"
    ;;
  ad-hoc|adhoc)
    DEFAULT_EXPORT_OPTIONS="${ROOT_DIR}/ExportOptions/AdHoc.plist"
    ;;
  app-store-connect|appstoreconnect)
    DEFAULT_EXPORT_OPTIONS="${ROOT_DIR}/ExportOptions/AppStoreConnect.plist"
    ;;
  app-store|appstore)
    DEFAULT_EXPORT_OPTIONS="${ROOT_DIR}/ExportOptions/AppStoreLegacy.plist"
    ;;
  *.plist)
    DEFAULT_EXPORT_OPTIONS="${EXPORT_KIND}"
    ;;
  *)
    fail "Unknown export kind: ${EXPORT_KIND}. Use development, ad-hoc, app-store-connect, app-store, or a plist path."
    ;;
esac

EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-${DEFAULT_EXPORT_OPTIONS}}"
[ -f "${EXPORT_OPTIONS_PLIST}" ] || fail "ExportOptions plist not found: ${EXPORT_OPTIONS_PLIST}"

if [ -z "${ARCHIVE_PATH:-}" ]; then
  if [ -f "${LATEST_ARCHIVE_FILE}" ]; then
    ARCHIVE_PATH="$(cat "${LATEST_ARCHIVE_FILE}")"
  fi
fi

if [ -z "${ARCHIVE_PATH:-}" ] || [ ! -d "${ARCHIVE_PATH}" ]; then
  log "No archive was provided. Creating a fresh archive first."
  bash "${SCRIPT_DIR}/archive.sh"
  ARCHIVE_PATH="$(cat "${LATEST_ARCHIVE_FILE}")"
fi

[ -d "${ARCHIVE_PATH}" ] || fail "Archive not found: ${ARCHIVE_PATH}"
mkdir -p "${EXPORT_PATH}"

print_environment
log "Exporting IPA"
log "Archive: ${ARCHIVE_PATH}"
log "ExportOptions: ${EXPORT_OPTIONS_PLIST}"
log "Export path: ${EXPORT_PATH}"

run_xcodebuild_logged "${LOG_FILE}" \
  xcodebuild \
  -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_PATH}" \
  -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
  -allowProvisioningUpdates

IPA_PATH="$(find "${EXPORT_PATH}" -maxdepth 1 -name '*.ipa' -print -quit)"
if [ -z "${IPA_PATH}" ]; then
  summarize_xcode_errors "${LOG_FILE}"
  fail "Export completed but no .ipa file was found in ${EXPORT_PATH}"
fi

log "IPA export succeeded"
log "IPA: ${IPA_PATH}"
log "Full log: ${LOG_FILE}"
