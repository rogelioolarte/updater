#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# migrate-old-kernels.sh
# Ubuntu 24.04+ — Update system, install current kernel, purge old kernels
# Usage: sudo ./migrate-old-kernels.sh [-n|--dry-run] [-v|--verbose] [-h|--help]
# -----------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# Default flags
DRY_RUN=false
VERBOSE=false
LOGFILE="/var/log/migrate-old-kernels.log"

# Color codes
readonly _GREEN="\033[0;32m"
readonly _YELLOW="\033[1;33m"
readonly _RED="\033[0;31m"
readonly _NC="\033[0m"  # No Color

# Print usage
usage() {
  cat << EOF
Usage: sudo $0 [options]
Options:
  -n, --dry-run    Show commands without executing them
  -v, --verbose    Print detailed output
  -h, --help       Display this help and exit
EOF
  exit 1
}

# Log wrapper
log() {
  local level="$1" message="$2"
  local timestamp; timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${timestamp} [${level}] ${message}" >> "$LOGFILE"
  if $VERBOSE; then
    echo -e "${timestamp} [${level}] ${message}"
  fi
}

# Run or print a command
run_cmd() {
  if $DRY_RUN; then
    echo -e "${_YELLOW}[DRY-RUN]${_NC} $*"
  else
    log "INFO" "Running: $*"
    "$@"
  fi
}

# Parse flags
while (( "$#" )); do
  case "$1" in
    -n|--dry-run) DRY_RUN=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -h|--help) usage ;;
    *) echo -e "${_RED}Unknown option:${_NC} $1"; usage ;;
  esac
done

# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo -e "${_RED}Error:${_NC} This script must be run as root." >&2
  exit 1
fi

# Start logging
touch "$LOGFILE"
log "INFO" "Script started. dry_run=$DRY_RUN, verbose=$VERBOSE"

echo -e "${_GREEN}Welcome, $(whoami)!${_NC}"
echo -e "${_GREEN}Logging to:${_NC} $LOGFILE"

# 1) System update
echo -e "${_YELLOW}Checking package database...${_NC}"
run_cmd apt-get check
echo -e "${_YELLOW}Updating package lists...${_NC}"
run_cmd apt-get update -y
echo -e "${_YELLOW}Upgrading installed packages...${_NC}"
run_cmd apt-get upgrade -y
run_cmd apt-get dist-upgrade -y
run_cmd apt-get full-upgrade -y
echo -e "${_GREEN}Removing unused packages...${_NC}"
run_cmd apt autoremove

# 2) Install the latest generic kernel meta-package
echo -e "${_YELLOW}Ensuring latest kernel meta-package is installed...${_NC}"
run_cmd apt-get install -y linux-image-generic linux-headers-generic

# 3) Determine current running kernel base version
CURRENT_KERNEL_FULL=$(uname -r)
CURRENT_KERNEL_BASE=${CURRENT_KERNEL_FULL%%-*}
echo -e "${_GREEN}Current running kernel: ${CURRENT_KERNEL_FULL}${_NC}"
log "INFO" "Cur"

