#!/usr/bin/env bash
# sys-report.sh — simple system info report for Debian/Ubuntu

# ─── COLORS ──────────────────────────────────────────────────────────────────
RED=$(tput setaf 1); GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3); BLUE=$(tput setaf 4)
BOLD=$(tput bold); RESET=$(tput sgr0)

# ─── HELP ────────────────────────────────────────────────────────────────────
function usage() {
  echo "Usage: $0"
  echo "Prints OS, kernel, uptime, load, CPU, RAM, disk and network info."
  exit 1
}

# ─── HEADER ──────────────────────────────────────────────────────────────────
function header() {
  echo "${BOLD}${BLUE}===== System Report for: $(hostname) =====${RESET}"
}

# ─── OS & KERNEL ─────────────────────────────────────────────────────────────
function os_info() {
  echo "${GREEN}* OS & Kernel:${RESET}"
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    echo "  • Distro: $NAME $VERSION"
  else
    echo -n "  • Distro: " && lsb_release -ds 2>/dev/null
  fi
  echo "  • Kernel: $(uname -sr)"
}

# ─── UPTIME & LOAD ───────────────────────────────────────────────────────────
function uptime_load() {
  local UP=$(awk '{print int($1/86400)"d "int(($1%86400)/3600)"h"}' /proc/uptime)
  echo "${GREEN}* Uptime & Load:${RESET}"
  echo "  • Uptime: $UP"
  echo "  • Load: $(cut -d ' ' -f1-3 /proc/loadavg)"
}

# ─── CPU ──────────────────────────────────────────────────────────────────────
function cpu_info() {
  echo "${GREEN}* CPU:${RESET}"
  awk -F: '/model name/ {print "  • "$2; exit}' /proc/cpuinfo
  awk -F: '/cpu cores/ {print "  • Cores: "$2; exit}' /proc/cpuinfo
}

# ─── RAM & SWAP ───────────────────────────────────────────────────────────────
function mem_info() {
  echo "${GREEN}* Memory (MiB):${RESET}"
  awk '/MemTotal|MemFree|SwapTotal|SwapFree/ {
    gsub(/ kB/,""); printf "  • %s: %.0f\n", $1, $2/1024
  }' /proc/meminfo
}

# ─── DISK USAGE ───────────────────────────────────────────────────────────────
function disk_info() {
  echo "${GREEN}* Disk Usage:${RESET}"
  df -h --output=target,pcent,size | sed '1d' | while read t p s; do
    printf "  • %-10s %6s / %s\n" "$t" "$p" "$s"
  done
}

# ─── NETWORK ─────────────────────────────────────────────────────────────────
function net_info() {
  echo "${GREEN}* Network Interfaces:${RESET}"
  ip -o -4 addr show up primary scope global | awk '{print "  • "$2": "$4}'
}

# ─── MAIN ────────────────────────────────────────────────────────────────────
if [[ $1 == "-h" || $1 == "--help" ]]; then usage; fi

header
os_info
echo
uptime_load
echo
cpu_info
echo
mem_info
echo
disk_info
echo
net_info
echo "${BOLD}${BLUE}==========================================${RESET}"
