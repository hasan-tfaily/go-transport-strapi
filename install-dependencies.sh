#!/bin/bash

# Strapi Production Deployment - System Dependencies Installer
# This script installs Node.js, npm, and PM2 if they are not already installed

# Don't exit on error immediately - we'll handle errors manually
set +e

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

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
    elif [ -f /etc/debian_version ]; then
        OS=debian
    elif [ -f /etc/redhat-release ]; then
        OS=rhel
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi
    echo "$OS"
}

# Function to install Node.js
install_nodejs() {
    OS=$(detect_os)
    echo -e "${YELLOW}Detected OS: $OS${NC}"
    echo -e "${YELLOW}Installing Node.js 20.x...${NC}"
    
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        echo "Installing Node.js for Ubuntu/Debian..."
        # Update package list
        if ! sudo apt-get update -qq; then
            echo -e "${RED}✗ Failed to update package list${NC}"
            return 1
        fi
        
        # Install required packages (curl, ca-certificates, gnupg)
        if ! sudo apt-get install -y -qq curl ca-certificates gnupg; then
            echo -e "${RED}✗ Failed to install required packages${NC}"
            return 1
        fi
        
        # Add NodeSource repository
        if ! curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
            echo -e "${RED}✗ Failed to add NodeSource repository${NC}"
            return 1
        fi
        
        # Install Node.js
        if ! sudo apt-get install -y -qq nodejs; then
            echo -e "${RED}✗ Failed to install Node.js${NC}"
            return 1
        fi
        
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "fedora" ]]; then
        echo "Installing Node.js for CentOS/RHEL/Fedora..."
        
        # Install curl if not present
        if ! command_exists curl; then
            if command_exists dnf; then
                sudo dnf install -y curl
            elif command_exists yum; then
                sudo yum install -y curl
            fi
        fi
        
        if command_exists dnf; then
            # Fedora or newer CentOS/RHEL
            if ! curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -; then
                echo -e "${RED}✗ Failed to add NodeSource repository${NC}"
                return 1
            fi
            if ! sudo dnf install -y nodejs; then
                echo -e "${RED}✗ Failed to install Node.js${NC}"
                return 1
            fi
        elif command_exists yum; then
            # Older CentOS/RHEL
            if ! curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -; then
                echo -e "${RED}✗ Failed to add NodeSource repository${NC}"
                return 1
            fi
            if ! sudo yum install -y nodejs; then
                echo -e "${RED}✗ Failed to install Node.js${NC}"
                return 1
            fi
        else
            echo -e "${RED}✗ Cannot determine package manager for $OS${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Unsupported OS: $OS${NC}"
        echo "Please install Node.js manually from https://nodejs.org/"
        return 1
    fi
    
    # Verify installation
    if command_exists node; then
        echo -e "${GREEN}✓ Node.js $(node -v) installed successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Node.js installation failed${NC}"
        return 1
    fi
}

# Check and install Node.js
echo ""
echo "Checking Node.js installation..."
if ! check_node_version; then
    if command_exists node; then
        echo -e "${YELLOW}Node.js version $(node -v) is incompatible, will install compatible version...${NC}"
        echo -e "${YELLOW}Note: The NodeSource setup script will handle removing the old version${NC}"
    else
        echo -e "${YELLOW}Node.js is not installed, installing...${NC}"
    fi
    
    if ! install_nodejs; then
        echo -e "${RED}✗ Failed to install Node.js${NC}"
        exit 1
    fi
    
    # Verify again after installation
    if ! check_node_version; then
        echo -e "${RED}✗ Installed Node.js version is still incompatible${NC}"
        exit 1
    fi
fi

# Check and install npm
echo ""
echo "Checking npm installation..."
if ! check_npm_version; then
    if command_exists node; then
        echo -e "${YELLOW}npm is missing or incompatible. Installing/updating npm...${NC}"
        # npm usually comes with Node.js, but let's ensure it's installed and updated
        sudo npm install -g npm@latest
        echo -e "${GREEN}✓ npm updated successfully${NC}"
    else
        echo -e "${RED}✗ Node.js is required to install npm${NC}"
        exit 1
    fi
    
    # Verify npm installation
    if ! check_npm_version; then
        echo -e "${RED}✗ npm installation/update failed${NC}"
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
if command_exists node; then
    echo -e "Node.js: ${GREEN}$(node -v)${NC}"
else
    echo -e "Node.js: ${RED}Not installed${NC}"
    exit 1
fi

if command_exists npm; then
    echo -e "npm: ${GREEN}$(npm -v)${NC}"
else
    echo -e "npm: ${RED}Not installed${NC}"
    exit 1
fi

if command_exists pm2; then
    echo -e "PM2: ${GREEN}$(pm2 -v)${NC}"
else
    echo -e "PM2: ${RED}Not installed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ All system dependencies are installed and ready!${NC}"
echo ""

