#!/usr/bin/env bash
#
# maintenance.sh — Debian/Ubuntu Comprehensive System Maintenance Tool
# Version: 1.0
# Author: Bocaletto Luca
# License: GPL
#
# Description:
#   This script performs a full suite of system maintenance tasks on Debian
#   and its derivatives without external dependencies. It updates package
#   lists, upgrades packages, handles distribution upgrades, cleans up
#   unused files, verifies package integrity, and checks if a reboot is needed.
#   All actions are logged to a timestamped file under /var/log/.
#
# Usage:
#   sudo ./maintenance.sh [OPTIONS]
#
# Options:
#   --update          Refresh package database (apt-get update)
#   --upgrade         Install package upgrades (apt-get upgrade -y)
#   --dist-upgrade    Perform distribution upgrade (apt-get dist-upgrade -y)
#   --full-upgrade    Alias for --dist-upgrade
#   --autoremove      Remove unused packages (apt-get autoremove --purge -y)
#   --autoclean       Clean cached package files (apt-get autoclean -y)
#   --check           Verify package consistency (apt-get check)
#   --reboot-check    Report if system reboot is required
#   --all             Run all of the above in logical order
#   -h, --help        Show this help and exit
#
# Logs:
#   /var/log/maintenance-YYYYMMDD-HHMMSS.log
#
# Example:
#   sudo ./maintenance.sh --all
#

set -euo pipefail

### ─── Configuration ──────────────────────────────────────────────────────────
LOG_DIR="/var/log"
TIMESTAMP="$(date +%F-%H%M%S)"
LOG_FILE="${LOG_DIR}/maintenance-${TIMESTAMP}.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"
exec > >(tee -a "${LOG_FILE}") 2>&1

### ─── Colors ─────────────────────────────────────────────────────────────────
RED=$(tput setaf 1)      # errors
GREEN=$(tput setaf 2)    # success
YELLOW=$(tput setaf 3)   # progress/info
CYAN=$(tput setaf 6)     # headings
RESET=$(tput sgr0)       # reset

### ─── Helpers ────────────────────────────────────────────────────────────────
function header() {
  echo
  echo "${CYAN}===== System Maintenance Started: $(date) =====${RESET}"
}

function footer() {
  echo
  echo "${CYAN}===== Maintenance Complete: $(date) =====${RESET}"
  echo "${CYAN}Log file:${RESET} ${LOG_FILE}"
  # Check for reboot requirement
  if [[ -f /var/run/reboot-required ]]; then
    echo "${YELLOW}*** REBOOT REQUIRED ***${RESET}"
  fi
  echo
}

function usage() {
  cat <<EOF
${CYAN}maintenance.sh${RESET} — Debian/Ubuntu Comprehensive Maintenance

Usage:
  sudo $0 [OPTIONS]

Options:
  --update          Refresh package database
  --upgrade         Install package upgrades
  --dist-upgrade    Perform distribution upgrade (alias: --full-upgrade)
  --full-upgrade    Alias for --dist-upgrade
  --autoremove      Remove unused packages
  --autoclean       Clean cached package files
  --check           Verify package consistency
  --reboot-check    Report if reboot is required (runs at end)
  --all             Run all steps in standard order
  -h, --help        Show this help and exit

Log:
  ${LOG_FILE}

Examples:
  sudo $0 --all
  sudo $0 --update --upgrade --autoremove

EOF
  exit 0
}

### ─── Privilege Check ────────────────────────────────────────────────────────
if (( EUID != 0 )); then
  echo "${RED}Error:${RESET} This script must be run as root."
  echo "Try: sudo $0 --help"
  exit 1
fi

### ─── Step Functions ─────────────────────────────────────────────────────────
function do_update() {
  echo "${YELLOW}[*] Updating package database...${RESET}"
  apt-get update -qq
  echo "${GREEN}[+] update completed.${RESET}"
}

function do_upgrade() {
  echo "${YELLOW}[*] Upgrading packages...${RESET}"
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
  echo "${GREEN}[+] upgrade completed.${RESET}"
}

function do_dist_upgrade() {
  echo "${YELLOW}[*] Performing dist-upgrade...${RESET}"
  DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y -qq
  echo "${GREEN}[+] dist-upgrade completed.${RESET}"
}

function do_autoremove() {
  echo "${YELLOW}[*] Removing unused packages...${RESET}"
  apt-get autoremove --purge -y -qq
  echo "${GREEN}[+] autoremove completed.${RESET}"
}

function do_autoclean() {
  echo "${YELLOW}[*] Cleaning package cache...${RESET}"
  apt-get autoclean -y -qq
  echo "${GREEN}[+] autoclean completed.${RESET}"
}

function do_check() {
  echo "${YELLOW}[*] Checking package integrity...${RESET}"
  apt-get check -qq
  echo "${GREEN}[+] check completed.${RESET}"
}

function do_reboot_check() {
  if [[ -f /var/run/reboot-required ]]; then
    echo "${YELLOW}*** Reboot is required! ***${RESET}"
  else
    echo "${GREEN}System does not require a reboot.${RESET}"
  fi
}

### ─── Parse Arguments ────────────────────────────────────────────────────────
# initialize flags
UPDATE=false; UPGRADE=false; DISTUP=false
AUTOREMOVE=false; AUTOCLEAN=false; CHECK=false; REBOOT_CHECK=false

if [[ $# -eq 0 ]]; then
  usage
fi

for arg in "$@"; do
  case "$arg" in
    --update)         UPDATE=true ;;
    --upgrade)        UPGRADE=true ;;
    --dist-upgrade)   DISTUP=true ;;
    --full-upgrade)   DISTUP=true ;;
    --autoremove)     AUTOREMOVE=true ;;
    --autoclean)      AUTOCLEAN=true ;;
    --check)          CHECK=true ;;
    --reboot-check)   REBOOT_CHECK=true ;;
    --all)
      UPDATE=true; UPGRADE=true; DISTUP=true
      AUTOREMOVE=true; AUTOCLEAN=true; CHECK=true; REBOOT_CHECK=true
      ;;
    -h|--help)        usage ;;
    *)
      echo "${RED}Error:${RESET} Unknown option '${arg}'"
      usage
      ;;
  esac
done

### ─── Main Execution ─────────────────────────────────────────────────────────
header

$UPDATE       && do_update
$UPGRADE      && do_upgrade
$DISTUP       && do_dist_upgrade
$AUTOREMOVE   && do_autoremove
$AUTOCLEAN    && do_autoclean
$CHECK        && do_check
$REBOOT_CHECK && do_reboot_check

footer
exit 0
