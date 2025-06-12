#!/usr/bin/env bash
#
# maintenance.sh — A simple Debian/Ubuntu system updater & upgrader
#
# Usage:
#   ./maintenance.sh [--update] [--upgrade] [--all] [-h|--help]
#
# Options:
#   --update      Run `apt-get update` to refresh package lists
#   --upgrade     Run `apt-get upgrade -y` to install available upgrades
#   --all         Perform both update and upgrade in sequence
#   -h, --help    Show this help and exit
#
# This script requires sudo privileges. It works out-of-the-box
# on Debian and derivatives (Ubuntu, Mint, etc.) without external deps.

set -euo pipefail

# ─── COLORS ───────────────────────────────────────────────────────────────────
RED=$(tput setaf 1)      # red for errors
GREEN=$(tput setaf 2)    # green for success messages
YELLOW=$(tput setaf 3)   # yellow for warnings
RESET=$(tput sgr0)       # reset color

# ─── PRINT HELP ───────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
maintenance.sh — A Debian/Ubuntu updater & upgrader

Usage:
  $0 [--update] [--upgrade] [--all] [-h|--help]

Options:
  --update      Refresh package database (apt-get update)
  --upgrade     Install all available upgrades (apt-get upgrade -y)
  --all         Do update then upgrade
  -h, --help    Display this help text
EOF
  exit 0
}

# ─── CHECK ROOT ────────────────────────────────────────────────────────────────
if (( EUID != 0 )); then
  echo "${RED}Error:${RESET} this script must be run as root."
  echo "Try: sudo $0"
  exit 1
fi

# ─── UPDATE FUNCTION ──────────────────────────────────────────────────────────
do_update() {
  echo "${YELLOW}[*] Running apt-get update...${RESET}"
  apt-get update -qq
  echo "${GREEN}[+] Package lists updated.${RESET}"
}

# ─── UPGRADE FUNCTION ─────────────────────────────────────────────────────────
do_upgrade() {
  echo "${YELLOW}[*] Running apt-get upgrade...${RESET}"
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
  echo "${GREEN}[+] All packages upgraded.${RESET}"
}

# ─── PARSE ARGUMENTS ──────────────────────────────────────────────────────────
if [[ $# -eq 0 ]]; then
  usage
fi

for arg in "$@"; do
  case "$arg" in
    --update)   STEP_UPDATE=true ;;
    --upgrade)  STEP_UPGRADE=true ;;
    --all)      STEP_UPDATE=true; STEP_UPGRADE=true ;;
    -h|--help)  usage ;;
    *) 
      echo "${RED}Error:${RESET} unknown option '$arg'"
      usage
      ;;
  esac
done

# ─── RUN REQUESTED STEPS ──────────────────────────────────────────────────────
echo "${GREEN}=== System Maintenance ===${RESET}"
[[ ${STEP_UPDATE:-false} == true ]]  && do_update
[[ ${STEP_UPGRADE:-false} == true ]] && do_upgrade
echo "${GREEN}=== Done ===${RESET}"
