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
HOOKS_DIR="$CLAUDE_DIR/hooks/rpi"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
RPI_HOOK_CMD="$HOME/.claude/hooks/rpi/session-info.py"

echo ""
echo "Note: For plugin installations, use: claude plugin uninstall rpi"
echo "  This script is for manual (legacy) installations only."
echo ""

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       RPI Workflow Uninstaller         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Confirm uninstall
echo -e "${YELLOW}This will remove:${NC}"
echo "  - $COMMANDS_DIR"
echo "  - $TEMPLATES_DIR"
echo "  - $HOOKS_DIR"
echo "  - RPI hook registration from settings.json"
echo ""
echo -e "${YELLOW}Note: Project docs (docs/rpi/, docs/research/, etc.) are preserved.${NC}"
echo ""
read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""

# Remove commands
echo -e "${GREEN}[1/4]${NC} Removing commands..."
if [ -d "$COMMANDS_DIR" ]; then
    rm -rf "$COMMANDS_DIR"
    echo "  ✓ Removed $COMMANDS_DIR"
else
    echo "  - $COMMANDS_DIR not found (skipped)"
fi
echo ""

# Remove templates
echo -e "${GREEN}[2/4]${NC} Removing templates..."
if [ -d "$TEMPLATES_DIR" ]; then
    rm -rf "$TEMPLATES_DIR"
    echo "  ✓ Removed $TEMPLATES_DIR"
else
    echo "  - $TEMPLATES_DIR not found (skipped)"
fi
echo ""

# Remove hooks
echo -e "${GREEN}[3/4]${NC} Removing hooks..."
if [ -d "$HOOKS_DIR" ]; then
    rm -rf "$HOOKS_DIR"
    echo "  ✓ Removed $HOOKS_DIR"
else
    echo "  - $HOOKS_DIR not found (skipped)"
fi
echo ""

# Deregister hook from settings.json
echo -e "${GREEN}[4/4]${NC} Deregistering hook from settings.json..."
if command -v jq &> /dev/null && [ -f "$SETTINGS_FILE" ]; then
    if jq -e ".hooks.UserPromptSubmit[]?.hooks[]? | select(.command == \"$RPI_HOOK_CMD\")" "$SETTINGS_FILE" > /dev/null 2>&1; then
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        jq --arg cmd "$RPI_HOOK_CMD" '
          .hooks.UserPromptSubmit = [
            .hooks.UserPromptSubmit[]? | select(.hooks | all(.command != $cmd))
          ] |
          if .hooks.UserPromptSubmit == [] then del(.hooks.UserPromptSubmit) else . end |
          if .hooks == {} then del(.hooks) else . end
        ' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
        echo "  ✓ RPI hook deregistered from settings.json"
    else
        echo "  - RPI hook not found in settings.json (skipped)"
    fi
else
    if ! command -v jq &> /dev/null; then
        echo -e "  ${YELLOW}⚠ jq not found. Manual hook removal may be needed.${NC}"
        echo "  Remove the RPI hook entry from ~/.claude/settings.json manually."
    else
        echo "  - settings.json not found (skipped)"
    fi
fi
echo ""

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Uninstall Complete!                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "RPI Workflow has been removed."
echo "Your project docs (docs/rpi/, docs/research/, etc.) are preserved."
