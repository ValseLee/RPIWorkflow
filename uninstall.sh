#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Target directories
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands/rpi"
TEMPLATES_DIR="$CLAUDE_DIR/rpi"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       RPI Workflow Uninstaller         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Confirm uninstall
echo -e "${YELLOW}This will remove:${NC}"
echo "  - $COMMANDS_DIR"
echo "  - $TEMPLATES_DIR (including rules/)"
echo ""
echo -e "${YELLOW}Note: Project-specific rules in rules/ will also be removed.${NC}"
echo ""
read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""

# Remove commands
echo -e "${GREEN}[1/2]${NC} Removing commands..."
if [ -d "$COMMANDS_DIR" ]; then
    rm -rf "$COMMANDS_DIR"
    echo "  ✓ Removed $COMMANDS_DIR"
else
    echo "  - $COMMANDS_DIR not found (skipped)"
fi
echo ""

# Remove templates
echo -e "${GREEN}[2/2]${NC} Removing templates..."
if [ -d "$TEMPLATES_DIR" ]; then
    rm -rf "$TEMPLATES_DIR"
    echo "  ✓ Removed $TEMPLATES_DIR"
else
    echo "  - $TEMPLATES_DIR not found (skipped)"
fi
echo ""

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Uninstall Complete!                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "RPI Workflow has been removed."
echo "Your project docs (docs/rpi/, docs/research/, etc.) are preserved."
