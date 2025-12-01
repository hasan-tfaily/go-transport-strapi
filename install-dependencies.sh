#!/bin/bash

# Strapi Production Deployment - System Dependencies Installer
# This script installs Node.js, npm, and PM2 if they are not already installed

set -e  # Exit on error

echo "========================================="
echo "Installing System Dependencies"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Node.js version
check_node_version() {
    if command_exists node; then
        NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 20 ] && [ "$NODE_VERSION" -le 24 ]; then
            echo -e "${GREEN}✓ Node.js version $(node -v) is compatible${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ Node.js version $(node -v) may not be compatible (requires >=20.0.0 <=24.x.x)${NC}"
            return 1
        fi
    else
        return 1
    fi
}

# Function to check npm version
check_npm_version() {
    if command_exists npm; then
        NPM_VERSION=$(npm -v | cut -d'.' -f1)
        if [ "$NPM_VERSION" -ge 6 ]; then
            echo -e "${GREEN}✓ npm version $(npm -v) is compatible${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ npm version $(npm -v) may not be compatible (requires >=6.0.0)${NC}"
            return 1
        fi
    else
        return 1
    fi
}

# Check and install Node.js
echo ""
echo "Checking Node.js installation..."
if ! check_node_version; then
    echo -e "${YELLOW}Node.js is not installed or version is incompatible${NC}"
    echo "Please install Node.js version 20.x, 21.x, 22.x, 23.x, or 24.x"
    echo ""
    echo "For Ubuntu/Debian, you can use:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    echo ""
    echo "For CentOS/RHEL, you can use:"
    echo "  curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -"
    echo "  sudo yum install -y nodejs"
    echo ""
    echo "Or visit: https://nodejs.org/"
    exit 1
fi

# Check and install npm
echo ""
echo "Checking npm installation..."
if ! check_npm_version; then
    echo -e "${YELLOW}npm is not installed or version is incompatible${NC}"
    echo "Installing/updating npm..."
    
    # Try to install npm using Node.js
    if command_exists node; then
        # npm usually comes with Node.js, but if it doesn't, we can install it
        echo "npm should come with Node.js. If it's missing, please install Node.js properly."
        echo "You can try: npm install -g npm@latest"
        exit 1
    else
        echo "Node.js is required to install npm. Please install Node.js first."
        exit 1
    fi
fi

# Check and install PM2
echo ""
echo "Checking PM2 installation..."
if ! command_exists pm2; then
    echo -e "${YELLOW}PM2 is not installed. Installing PM2 globally...${NC}"
    sudo npm install -g pm2
    echo -e "${GREEN}✓ PM2 installed successfully${NC}"
    
    # Setup PM2 startup script
    echo ""
    echo "Setting up PM2 startup script..."
    sudo pm2 startup
    echo -e "${GREEN}✓ PM2 startup script configured${NC}"
    echo -e "${YELLOW}Note: You may need to run the command shown above to enable PM2 on system boot${NC}"
else
    PM2_VERSION=$(pm2 -v)
    echo -e "${GREEN}✓ PM2 version $PM2_VERSION is already installed${NC}"
    
    # Check if PM2 startup is configured
    if ! pm2 startup | grep -q "already setup"; then
        echo ""
        echo "PM2 startup script is not configured. Setting it up..."
        sudo pm2 startup
        echo -e "${YELLOW}Note: You may need to run the command shown above to enable PM2 on system boot${NC}"
    fi
fi

# Verify installations
echo ""
echo "========================================="
echo "Verification Summary"
echo "========================================="
echo -e "Node.js: ${GREEN}$(node -v)${NC}"
echo -e "npm: ${GREEN}$(npm -v)${NC}"
echo -e "PM2: ${GREEN}$(pm2 -v)${NC}"
echo ""
echo -e "${GREEN}✓ All system dependencies are installed and ready!${NC}"
echo ""

