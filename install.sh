#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory (where RPI Workflow is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directories
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands/rpi"
TEMPLATES_DIR="$CLAUDE_DIR/rpi"
RULES_DIR="$TEMPLATES_DIR/rules"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       RPI Workflow Installer           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if source files exist
if [ ! -d "$SCRIPT_DIR/commands" ] || [ ! -d "$SCRIPT_DIR/templates" ]; then
    echo -e "${RED}Error: commands/ or templates/ directory not found.${NC}"
    echo "Please run this script from the RPIWorkflow directory."
    exit 1
fi

# Function to backup existing files
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}  Backing up existing: $target${NC}"
        mv "$target" "$backup"
        echo -e "${YELLOW}  → Saved to: $backup${NC}"
    fi
}

# Create directories
echo -e "${GREEN}[1/5]${NC} Creating directories..."
mkdir -p "$COMMANDS_DIR"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$RULES_DIR/architecture"
mkdir -p "$RULES_DIR/patterns"
mkdir -p "$RULES_DIR/dependencies"
mkdir -p "$RULES_DIR/testing"
echo "  ✓ $COMMANDS_DIR"
echo "  ✓ $TEMPLATES_DIR"
echo "  ✓ $RULES_DIR/{architecture,patterns,dependencies,testing}"
echo ""

# Install commands
echo -e "${GREEN}[2/5]${NC} Installing commands..."
for file in "$SCRIPT_DIR/commands"/*.md; do
    filename=$(basename "$file")
    target="$COMMANDS_DIR/$filename"
    backup_if_exists "$target"
    cp "$file" "$target"
    echo "  ✓ /rpi:${filename%.md}"
done
echo ""

# Install templates
echo -e "${GREEN}[3/5]${NC} Installing templates..."
for file in "$SCRIPT_DIR/templates"/*.md; do
    filename=$(basename "$file")
    target="$TEMPLATES_DIR/$filename"
    backup_if_exists "$target"
    cp "$file" "$target"
    echo "  ✓ $filename"
done
echo ""

# Install rule examples
echo -e "${GREEN}[4/5]${NC} Installing rule examples..."
if [ -d "$SCRIPT_DIR/templates/rules" ]; then
    for file in "$SCRIPT_DIR/templates/rules"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            target="$TEMPLATES_DIR/rules/$filename"
            backup_if_exists "$target"
            cp "$file" "$target"
            echo "  ✓ $filename"
        fi
    done
else
    echo "  (no rule examples found)"
fi
echo ""

# Verify installation
echo -e "${GREEN}[5/5]${NC} Verifying installation..."
errors=0

for cmd in research plan implement rule; do
    if [ -f "$COMMANDS_DIR/${cmd}.md" ]; then
        echo "  ✓ /rpi:$cmd"
    else
        echo -e "  ${RED}✗ /rpi:$cmd missing${NC}"
        ((errors++))
    fi
done

for tpl in rpi-main-template research-template plan-template rule-template; do
    if [ -f "$TEMPLATES_DIR/${tpl}.md" ]; then
        echo "  ✓ $tpl.md"
    else
        echo -e "  ${RED}✗ $tpl.md missing${NC}"
        ((errors++))
    fi
done

# Check rule directories
for ruletype in architecture patterns dependencies testing; do
    if [ -d "$RULES_DIR/$ruletype" ]; then
        echo "  ✓ rules/$ruletype/"
    else
        echo -e "  ${RED}✗ rules/$ruletype/ missing${NC}"
        ((errors++))
    fi
done
echo ""

# Summary
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Installation Complete!             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Available commands:"
    echo "  /rpi:research  - Start research phase"
    echo "  /rpi:plan      - Create implementation plan"
    echo "  /rpi:implement - Execute the plan"
    echo "  /rpi:rule      - Manage project-specific rules"
    echo ""
    echo "Rule directories created at:"
    echo "  $RULES_DIR/"
    echo ""
    echo "Restart Claude Code or start a new session to use."
else
    echo -e "${RED}Installation completed with $errors error(s).${NC}"
    echo "Please check the missing files and try again."
    exit 1
fi
