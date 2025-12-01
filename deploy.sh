#!/bin/bash

# Strapi Production Deployment Script
# This script handles the complete deployment process including:
# - Dependency installation
# - Building the project
# - Starting/restarting with PM2

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "========================================="
echo "Strapi Production Deployment"
echo "========================================="
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check prerequisites
echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"
echo ""

# Check Node.js
if ! command_exists node; then
    echo -e "${RED}✗ Node.js is not installed${NC}"
    echo "Please run ./install-dependencies.sh first"
    exit 1
fi

NODE_VERSION=$(node -v)
NODE_MAJOR=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_MAJOR" -lt 20 ] || [ "$NODE_MAJOR" -gt 24 ]; then
    echo -e "${RED}✗ Node.js version $NODE_VERSION is not compatible (requires >=20.0.0 <=24.x.x)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $NODE_VERSION${NC}"

# Check npm
if ! command_exists npm; then
    echo -e "${RED}✗ npm is not installed${NC}"
    echo "Please run ./install-dependencies.sh first"
    exit 1
fi
echo -e "${GREEN}✓ npm $(npm -v)${NC}"

# Check PM2
if ! command_exists pm2; then
    echo -e "${YELLOW}⚠ PM2 is not installed. Installing...${NC}"
    sudo npm install -g pm2
fi
echo -e "${GREEN}✓ PM2 $(pm2 -v)${NC}"

echo ""

# Step 2: Check for .env file
echo -e "${BLUE}Step 2: Checking environment configuration...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠ .env file not found${NC}"
    if [ -f .env.example ]; then
        echo "Creating .env from .env.example..."
        cp .env.example .env
        echo -e "${YELLOW}⚠ Please edit .env file and add your configuration values${NC}"
        echo -e "${YELLOW}⚠ Especially important: APP_KEYS, ADMIN_JWT_SECRET, API_TOKEN_SALT, TRANSFER_TOKEN_SALT, ENCRYPTION_KEY${NC}"
        echo ""
        read -p "Press Enter to continue after editing .env file, or Ctrl+C to abort..."
    else
        echo -e "${RED}✗ .env.example file not found. Please create .env file manually.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ .env file found${NC}"
fi

# Validate critical environment variables
echo "Validating critical environment variables..."
source .env 2>/dev/null || true

if [ -z "$APP_KEYS" ] || [ "$APP_KEYS" = "toBeModified1,toBeModified2,toBeModified3,toBeModified4" ]; then
    echo -e "${YELLOW}⚠ Warning: APP_KEYS appears to be using default values. Please update them in .env${NC}"
fi

if [ -z "$ADMIN_JWT_SECRET" ] || [ "$ADMIN_JWT_SECRET" = "toBeModified" ]; then
    echo -e "${YELLOW}⚠ Warning: ADMIN_JWT_SECRET appears to be using default values. Please update them in .env${NC}"
fi

echo ""

# Step 3: Install npm dependencies
echo -e "${BLUE}Step 3: Installing npm dependencies...${NC}"
if [ -f package-lock.json ]; then
    echo "Using package-lock.json for consistent installs..."
    npm ci
else
    echo "Installing dependencies..."
    npm install
fi
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Step 4: Create logs directory
echo -e "${BLUE}Step 4: Setting up logs directory...${NC}"
mkdir -p logs
echo -e "${GREEN}✓ Logs directory ready${NC}"
echo ""

# Step 5: Build the project
echo -e "${BLUE}Step 5: Building Strapi project...${NC}"
echo "This may take a few minutes..."
npm run build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build completed successfully${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
echo ""

# Step 6: Check for existing PM2 process
echo -e "${BLUE}Step 6: Managing PM2 process...${NC}"
if pm2 list | grep -q "strapi"; then
    echo "Strapi is already running in PM2. Restarting..."
    pm2 restart strapi
    echo -e "${GREEN}✓ Strapi restarted${NC}"
else
    echo "Starting Strapi with PM2..."
    pm2 start ecosystem.config.js
    echo -e "${GREEN}✓ Strapi started${NC}"
fi

# Save PM2 process list
pm2 save

echo ""

# Step 7: Display status
echo -e "${BLUE}Step 7: Deployment Status${NC}"
echo "========================================="
pm2 status
echo ""
echo -e "${GREEN}✓ Deployment completed successfully!${NC}"
echo ""
echo "Useful commands:"
echo "  pm2 status              - Check application status"
echo "  pm2 logs strapi         - View application logs"
echo "  pm2 logs strapi --lines 100  - View last 100 lines"
echo "  pm2 restart strapi      - Restart the application"
echo "  pm2 stop strapi         - Stop the application"
echo "  pm2 delete strapi       - Remove from PM2"
echo ""
echo "Log files are located in: ./logs/"
echo ""

