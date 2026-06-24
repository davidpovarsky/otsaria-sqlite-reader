#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_PATH="${PROJECT_PATH:-${ROOT_DIR}/OtsariaReader.xcodeproj}"
SCHEME="${SCHEME:-OtsariaReader}"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${ROOT_DIR}/build/DerivedData}"
OUTPUT_DIR="${OUTPUT_DIR:-${ROOT_DIR}/build/output}"
ARCHIVE_DIR="${ARCHIVE_DIR:-${ROOT_DIR}/build/archives}"
LOG_DIR="${LOG_DIR:-${ROOT_DIR}/build/logs}"
LATEST_ARCHIVE_FILE="${ROOT_DIR}/build/latest-archive-path.txt"

mkdir -p "${DERIVED_DATA_PATH}" "${OUTPUT_DIR}" "${ARCHIVE_DIR}" "${LOG_DIR}"

timestamp() {
  date +"%Y%m%d-%H%M%S"
}

log() {
  printf '[%s] %s\n' "$(date +"%H:%M:%S")" "$*"
}

fail() {
  printf '\nERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

print_environment() {
  log "Repository: ${ROOT_DIR}"
  log "Project: ${PROJECT_PATH}"
  log "Scheme: ${SCHEME}"
  log "Configuration: ${CONFIGURATION}"
  log "DerivedData: ${DERIVED_DATA_PATH}"
  log "Logs: ${LOG_DIR}"
  if command -v xcodebuild >/dev/null 2>&1; then
    xcodebuild -version || true
  fi
  if command -v xcrun >/dev/null 2>&1; then
    xcrun --sdk iphoneos --show-sdk-version 2>/dev/null || true
  fi
}

summarize_xcode_errors() {
  local log_file="$1"
  printf '\n================ COPY THIS ERROR SUMMARY ================\n'
  printf 'Log file: %s\n\n' "${log_file}"

  if [ ! -f "${log_file}" ]; then
    printf 'No log file was created.\n'
    printf '=========================================================\n'
    return 0
  fi

  grep -nE \
    '(^|[[:space:]])error:|xcodebuild: error|The following build commands failed|BUILD FAILED|ARCHIVE FAILED|EXPORT FAILED|CodeSign|codesign|Signing for|No profiles for|requires a provisioning profile|Provisioning profile|No signing certificate|SwiftCompile|CompileSwift|Ld |clang: error|fatal error:' \
    "${log_file}" | tail -n 160 || true

  printf '\nLast 80 log lines:\n'
  tail -n 80 "${log_file}" || true
  printf '================ END COPY THIS ERROR SUMMARY =============\n'
}

run_xcodebuild_logged() {
  local log_file="$1"
  shift

  log "Writing full xcodebuild log to: ${log_file}"
  log "Command: $*"

  set +e
  "$@" 2>&1 | tee "${log_file}"
  local status=${PIPESTATUS[0]}
  set -e

  if [ "${status}" -ne 0 ]; then
    summarize_xcode_errors "${log_file}"
    exit "${status}"
  fi
}
