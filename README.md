# maintenance.sh
#### Author: Bocaletto Luca

> **Comprehensive System Maintenance Tool for Debian & Ubuntu**

<p align="center">
  <a href="https://github.com/bocaletto-luca/maintenance.sh/blob/main/maintenance.sh">
    <img src="https://img.shields.io/badge/version-2.0-blue.svg" alt="Version 2.0" />
  </a>
  <a href="https://github.com/bocaletto-luca/maintenance.sh/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="MIT License" />
  </a>
</p>

---

## 📋 Description

`maintenance.sh` is a zero-dependency Bash script that performs a full suite of system-maintenance tasks on Debian and its derivatives.  
All actions are logged to `/var/log/maintenance-YYYYMMDD-HHMMSS.log`.  

**Features**  
- Refresh package lists (`--update`)  
- Install available upgrades (`--upgrade`)  
- Perform distribution upgrades (`--dist-upgrade` / `--full-upgrade`)  
- Remove unused packages (`--autoremove`)  
- Clean cached `.deb` files (`--autoclean`)  
- Verify package integrity (`--check`)  
- Report reboot requirement (`--reboot-check`)  
- “All-in-one” mode (`--all`)  
- Colorized output & timestamped logging  
- Final reboot prompt if required  

---

## ⚙️ Prerequisites

- Debian, Ubuntu, Mint or any APT-based distribution  
- Bash (v4+)  
- No external packages or libraries—uses only coreutils, `apt-get`, `tput`, `tee`, `curl`, `date`

---

## 🚀 Installation

#### bash
# Clone this repository
    git clone https://github.com/bocaletto-luca/maintenance.sh.git
    cd maintenance.sh

# Make the script executable
    chmod +x maintenance.sh

# (Optional) Move to a system PATH location
    sudo mv maintenance.sh /usr/local/bin/maintenance.sh

## 🛠️ Usage

#### Run the script with sudo and any combination of options:

    sudo ./maintenance.sh [OPTIONS]

## Example:

    # Update package lists only
    sudo ./maintenance.sh --update

#### Full maintenance run
    sudo ./maintenance.sh --all

#### Custom sequence: update + autoremove
    sudo ./maintenance.sh --update --autoremove

## 📂 Log Files

#### Logs are stored under:
    /var/log/maintenance-YYYYMMDD-HHMMSS.log

## Review or archive these files for auditing.

## 👤 Author

### Bocaletto Luca Full-Stack Developer & Linux Enthusiast

## 📄 License

#### This project is released under the GPL License. Fell free to use, modify, and distribute! 
