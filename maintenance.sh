#!/usr/bin/env bash
#
# maintenance.sh — Debian/Ubuntu System Maintenance Script
# Version: 1.1
# Author: Bocaletto Luca
# License: MIT
#
# Description:
#   Performs apt-get update, upgrade, dist-upgrade, autoremove, autoclean,
#   and check. Designed to run out-of-the-box on Debian & derivatives.
#
# Usage:
#   sudo maintenance.sh [OPTIONS]
#
# Options:
#   --update         Refresh package database (apt-get update)
#   --upgrade        Install available upgrades (apt-get upgrade -y)
#   --dist-upgrade   Install distribution upgrades (apt-get dist-upgrade -y)
#   --autoremove     Remove unused packages (apt-get autoremove -y)
#   --autoclean      Remove cached .deb files (apt-get autoclean -y)
#   --all            Run update, upgrade, dist-upgrade, autoremove, autoclean
#   --check          Run apt-get check for dependency problems
#   -h, --help       Display this help and exit
#
# Examples:
#   sudo maintenance.sh --all
#   sudo maintenance.sh --update --upgrade --autoremove
#   sudo maintenance.sh --help
#

set -euo pipefail

# ─── COLORS ───────────────────────────────────────────────────────────────────
RED=$(tput setaf 1)      # errors
GREEN=$(tput setaf 2)    # success
YELLOW=$(tput setaf 3)   # progress
CYAN=$(tput setaf 6)     # info
RESET=$(tput sgr0)       # reset

# ─── PRINT HELP ────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${CYAN}maintenance.sh${RESET} — Debian/Ubuntu System Maintenance

Usage:
  sudo $0 [OPTIONS]

Options:
  --update         Refresh package database (apt-get update)
  --upgrade        Install available upgrades (apt-get upgrade -y)
  --dist-upgrade   Install distribution upgrades (apt-get dist-upgrade -y)
  --autoremove     Remove unused packages (apt-get autoremove -y)
  --autoclean      Remove cached package files (apt-get autoclean -y)
  --check          Verify package consistency (apt-get check)
  --all            Run update, upgrade, dist-upgrade, autoremove, autoclean
  -h, --help       Show this help and exit

Examples:
  sudo $0 --all
  sudo $0 --update --upgrade --autoremove
EOF
  exit 0
}

# ─── REQUIRE ROOT ──────────────────────────────────────────────────────────────
if (( EUID != 0 )); then
  echo "${RED}Error:${RESET} This script must be run as root."
  exit 1
fi

# ─── STEP FUNCTIONS ────────────────────────────────────────────────────────────
do_update() {
  echo "${YELLOW}[*] Updating package database...${RESET}"
  apt-get update -qq
  echo "${GREEN}[+] Package database updated.${RESET}"
}

do_upgrade() {
  echo "${YELLOW}[*] Upgrading packages...${RESET}"
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
  echo "${GREEN}[+] Packages upgraded.${RESET}"
}

do_dist_upgrade() {
  echo "${YELLOW}[*] Performing dist-upgrade...${RESET}"
  DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y -qq
  echo "${GREEN}[+] Dist-upgrade complete.${RESET}"
}

do_autoremove() {
  echo "${YELLOW}[*] Removing unused packages...${RESET}"
  apt-get autoremove -y -qq
  echo "${GREEN}[+] Unused packages removed.${RESET}"
}

do_autoclean() {
  echo "${YELLOW}[*] Cleaning package cache...${RESET}"
  apt-get autoclean -y -qq
  echo "${GREEN}[+] Package cache cleaned.${RESET}"
}

do_check() {
  echo "${YELLOW}[*] Checking package consistency...${RESET}"
  apt-get check -qq
  echo "${GREEN}[+] Package check passed.${RESET}"
}

# ─── PARSE ARGUMENTS ──────────────────────────────────────────────────────────
if [[ $# -eq 0 ]]; then
  usage
fi

# Initialize flags
STEP_UPDATE=false
STEP_UPGRADE=false
STEP_DISTUPGRADE=false
STEP_AUTOREMOVE=false
STEP_AUTOCLEAN=false
STEP_CHECK=false

for arg in "$@"; do
  case "$arg" in
    --update)       STEP_UPDATE=true ;;
    --upgrade)      STEP_UPGRADE=true ;;
    --dist-upgrade) STEP_DISTUPGRADE=true ;;
    --autoremove)   STEP_AUTOREMOVE=true ;;
    --autoclean)    STEP_AUTOCLEAN=true ;;
    --check)        STEP_CHECK=true ;;
    --all)
      STEP_UPDATE=true
      STEP_UPGRADE=true
      STEP_DISTUPGRADE=true
      STEP_AUTOREMOVE=true
      STEP_AUTOCLEAN=true
      ;;
    -h|--help)      usage ;;
    *)
      echo "${RED}Error:${RESET} Unknown option '$arg'"
      usage
      ;;
  esac
done

# ─── EXECUTION ─────────────────────────────────────────────────────────────────
echo "${CYAN}=== Starting System Maintenance ===${RESET}"

$STEP_UPDATE       && do_update
$STEP_UPGRADE      && do_upgrade
$STEP_DISTUPGRADE  && do_dist_upgrade
$STEP_AUTOREMOVE   && do_autoremove
$STEP_AUTOCLEAN    && do_autoclean
$STEP_CHECK        && do_check

echo "${CYAN}=== Maintenance Complete! ===${RESET}"
exit 0
