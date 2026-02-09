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
HOOKS_DIR="$CLAUDE_DIR/hooks/rpi"

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
echo -e "${GREEN}[1/6]${NC} Creating directories..."
mkdir -p "$COMMANDS_DIR"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$HOOKS_DIR"
echo "  ✓ $COMMANDS_DIR"
echo "  ✓ $TEMPLATES_DIR"
echo "  ✓ $HOOKS_DIR"
echo ""

# Install commands
echo -e "${GREEN}[2/6]${NC} Installing commands..."
for file in "$SCRIPT_DIR/commands"/*.md; do
    filename=$(basename "$file")
    target="$COMMANDS_DIR/$filename"
    backup_if_exists "$target"
    cp "$file" "$target"
    echo "  ✓ /rpi:${filename%.md}"
done
echo ""

# Install templates
echo -e "${GREEN}[3/6]${NC} Installing templates..."
for file in "$SCRIPT_DIR/templates"/*.md; do
    filename=$(basename "$file")
    target="$TEMPLATES_DIR/$filename"
    backup_if_exists "$target"
    cp "$file" "$target"
    echo "  ✓ $filename"
done
echo ""

# Install hooks
echo -e "${GREEN}[4/6]${NC} Installing hooks..."
for file in "$SCRIPT_DIR/hooks"/*; do
    filename=$(basename "$file")
    target="$HOOKS_DIR/$filename"
    backup_if_exists "$target"
    cp "$file" "$target"
    chmod +x "$target"
    echo "  ✓ $filename"
done
echo ""

# Register hook in settings.json
echo -e "${GREEN}[5/6]${NC} Registering hook in settings.json..."
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
RPI_HOOK_CMD="$HOME/.claude/hooks/rpi/session-info.py"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}  ⚠ jq not found. Manual hook registration required.${NC}"
    echo -e "${YELLOW}  Add this to ~/.claude/settings.json:${NC}"
    echo ""
    cat << HOOK_CONFIG
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$RPI_HOOK_CMD"
          }
        ]
      }
    ]
  }
}
HOOK_CONFIG
    echo ""
else
    # Create settings.json if not exists
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo '{}' > "$SETTINGS_FILE"
        echo "  ✓ Created $SETTINGS_FILE"
    fi

    # Check if RPI hook already registered
    if jq -e ".hooks.UserPromptSubmit[]?.hooks[]? | select(.command == \"$RPI_HOOK_CMD\")" "$SETTINGS_FILE" > /dev/null 2>&1; then
        echo "  ✓ RPI hook already registered"
    else
        # Backup settings.json
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

        # Add RPI hook to UserPromptSubmit array
        RPI_HOOK_ENTRY='{"hooks": [{"type": "command", "command": "'"$RPI_HOOK_CMD"'"}]}'

        # Merge hook into settings
        jq --argjson hook "$RPI_HOOK_ENTRY" '
          .hooks //= {} |
          .hooks.UserPromptSubmit //= [] |
          .hooks.UserPromptSubmit += [$hook]
        ' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

        echo "  ✓ RPI hook registered in settings.json"
    fi
fi
echo ""

# Verify installation
echo -e "${GREEN}[6/6]${NC} Verifying installation..."
errors=0

for cmd in research plan implement verify rule; do
    if [ -f "$COMMANDS_DIR/${cmd}.md" ]; then
        echo "  ✓ /rpi:$cmd"
    else
        echo -e "  ${RED}✗ /rpi:$cmd missing${NC}"
        ((errors++))
    fi
done

for tpl in rpi-main-template research-template plan-template verify-template rule-template; do
    if [ -f "$TEMPLATES_DIR/${tpl}.md" ]; then
        echo "  ✓ $tpl.md"
    else
        echo -e "  ${RED}✗ $tpl.md missing${NC}"
        ((errors++))
    fi
done

# Verify hooks
if [ -f "$HOOKS_DIR/session-info.py" ]; then
    echo "  ✓ session-info.py hook file"
else
    echo -e "  ${RED}✗ session-info.py hook file missing${NC}"
    ((errors++))
fi

# Verify hook registration
if command -v jq &> /dev/null && [ -f "$SETTINGS_FILE" ]; then
    if jq -e ".hooks.UserPromptSubmit[]?.hooks[]? | select(.command == \"$RPI_HOOK_CMD\")" "$SETTINGS_FILE" > /dev/null 2>&1; then
        echo "  ✓ session-info.py hook registered"
    else
        echo -e "  ${YELLOW}⚠ session-info.py hook not registered in settings.json${NC}"
    fi
fi

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
    echo "  /rpi:verify    - Validate implementation"
    echo "  /rpi:rule      - Manage project-specific rules"
    echo ""
    echo "Rules are stored per-project at: <project>/.claude/rules/"
    echo ""
    echo "Restart Claude Code or start a new session to use."
else
    echo -e "${RED}Installation completed with $errors error(s).${NC}"
    echo "Please check the missing files and try again."
    exit 1
fi
