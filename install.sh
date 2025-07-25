#!/bin/bash
# Quick Superuser Terminal Installer
# Version: 1.1-enhanced
# Make executable with: chmod +x install.sh

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}Enhanced Superuser Terminal Quick Installer${NC}"
echo "=============================================="

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This installer must be run as root${NC}"
    echo "Please run: su -c '$0' or sudo $0"
    exit 1
fi

echo -e "${GREEN}✓ Root access confirmed${NC}"

# Check if main script exists
if [ ! -f "Superuser_main" ]; then
    echo -e "${RED}Error: Superuser_main script not found in current directory${NC}"
    echo "Please run this installer from the same directory as Superuser_main"
    exit 1
fi

echo -e "${GREEN}✓ Main script found${NC}"

# Run the build command
echo -e "${CYAN}Building superuser directory structure...${NC}"
./Superuser_main build

# Install main script
echo -e "${CYAN}Installing main script...${NC}"
cp Superuser_main /data/superuser/bin/
chmod +x /data/superuser/bin/Superuser_main
echo -e "${GREEN}✓ Main script installed to /data/superuser/bin/${NC}"

# Install utility script if available
if [ -f "superuser-utils.sh" ]; then
    echo -e "${CYAN}Installing utility script...${NC}"
    cp superuser-utils.sh /data/superuser/bin/
    chmod +x /data/superuser/bin/superuser-utils.sh
    echo -e "${GREEN}✓ Utility script installed${NC}"
fi

# Install configuration script if available
if [ -f "configure.sh" ]; then
    echo -e "${CYAN}Installing configuration script...${NC}"
    cp configure.sh /data/superuser/bin/
    chmod +x /data/superuser/bin/configure.sh
    echo -e "${GREEN}✓ Configuration script installed${NC}"
fi

# Install advanced logger if available
if [ -f "advanced-logger.sh" ]; then
    echo -e "${CYAN}Installing advanced logger...${NC}"
    cp advanced-logger.sh /data/superuser/bin/
    chmod +x /data/superuser/bin/advanced-logger.sh
    echo -e "${GREEN}✓ Advanced logger installed${NC}"
fi

# Install system repair utility if available
if [ -f "system-repair.sh" ]; then
    echo -e "${CYAN}Installing system repair utility...${NC}"
    cp system-repair.sh /data/superuser/bin/
    chmod +x /data/superuser/bin/system-repair.sh
    echo -e "${GREEN}✓ System repair utility installed${NC}"
fi

# Install test framework if available
if [ -f "test-framework.sh" ]; then
    echo -e "${CYAN}Installing test framework...${NC}"
    cp test-framework.sh /data/superuser/bin/
    chmod +x /data/superuser/bin/test-framework.sh
    echo -e "${GREEN}✓ Test framework installed${NC}"
fi

# Create symlinks for easy access
echo -e "${CYAN}Creating convenient symlinks...${NC}"
if [ -w "/system/bin" ]; then
    ln -sf /data/superuser/bin/Superuser_main /system/bin/superuser 2>/dev/null || true
    ln -sf /data/superuser/bin/superuser-tool /system/bin/su-tool 2>/dev/null || true
    echo -e "${GREEN}✓ System symlinks created${NC}"
else
    echo -e "${YELLOW}! Cannot create system symlinks (read-only filesystem)${NC}"
fi

# Update PATH for current session
export PATH="/data/superuser/bin:$PATH"

echo ""
echo -e "${GREEN}Installation completed successfully!${NC}"
echo ""
echo "📚 Documentation:"
echo "  README.md           - Complete documentation"
echo "  COMMANDS.md         - Command reference"
echo "  QUICKREF.md         - Quick reference card"
echo ""
echo "🛠️ Core Tools:"
echo "  superuser [command]     - Main superuser terminal"
echo "  superuser-tool [cmd]    - Tool launcher"
echo "  superuser-utils.sh      - Quick utilities"
echo ""
echo "🔧 Advanced Tools:"
echo "  configure.sh            - Advanced configuration manager"
echo "  advanced-logger.sh      - Logging system"
echo "  system-repair.sh        - System repair utility"
echo "  test-framework.sh       - Comprehensive testing"
echo ""
echo "🚀 Available commands:"
echo "  check, fix, backup, interactive, benchmark, security, network, android"
echo "  health, performance, monitor, test, deps, repair"
echo ""
echo "🎮 Quick start examples:"
echo "  superuser interactive   - Interactive mode"
echo "  superuser check         - System check"
echo "  superuser health        - Health monitor"
echo "  superuser test          - Run tests"
echo "  system-repair.sh        - System repair"
echo "  test-framework.sh       - Run test suite"
echo ""
echo -e "${CYAN}🎉 Enhanced Superuser Terminal is ready for action!${NC}"
echo -e "${BLUE}💡 Tip: Run 'superuser help' for detailed command information${NC}"