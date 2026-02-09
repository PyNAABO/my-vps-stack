#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running in Termux
if [ -n "$TERMUX_VERSION" ]; then
    IS_TERMUX=true
else
    IS_TERMUX=false
fi

# Root check (only for non-Termux)
if [ "$IS_TERMUX" = false ] && [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root on a VPS.${NC}"
    exit 1
fi

echo -e "${YELLOW}🚀 Starting System Update...${NC}"

# Stop on error
set -e

# Error trap
trap 'echo -e "${RED}❌ Error occurred at line $LINENO. Update aborted.${NC}"; exit 1' ERR

if [ "$IS_TERMUX" = true ]; then
    # --- Termux Update Logic ---
    echo -e "${GREEN}[1/3] Updating package lists...${NC}"
    pkg update -y
    
    echo -e "${GREEN}[2/3] Upgrading installed packages...${NC}"
    pkg upgrade -y
    
    echo -e "${GREEN}[3/3] Cleaning up...${NC}"
    pkg autoclean
    
    echo -e "${GREEN}✅ Termux is up to date!${NC}"
else
    # --- VPS/Debian Update Logic ---
    # 1. Update the list of available packages
    echo -e "${GREEN}[1/4] Updating package lists...${NC}"
    apt update

    # 2. Upgrade the actual packages (auto-confirm with -y)
    echo -e "${GREEN}[2/4] Upgrading installed packages...${NC}"
    apt upgrade -y

    # 3. Clean up junk (old versions, unused dependencies)
    echo -e "${GREEN}[3/4] Cleaning up junk files...${NC}"
    apt autoremove -y
    apt autoclean

    # 4. Check if a reboot is required
    echo -e "${GREEN}[4/4] Checking health...${NC}"
    if [ -f /var/run/reboot-required ]; then
        echo -e "${RED}⚠️  REBOOT REQUIRED! A kernel update was installed.${NC}"
        echo -e "Type 'reboot' to restart now."
    else
        echo -e "${GREEN}✅ System is fresh and good to go!${NC}"
    fi
fi
