#!/bin/bash
# Install POC skill hooks and project-level settings
# Run once after installing the skill

set -e

# Find the skill directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

echo "POC Skill Installer"
echo "==================="
echo ""
echo "Skill directory: $SKILL_DIR"

# Load or prompt for POC_ROOT
CONFIG_FILE="$HOME/.config/poc/config.json"
if [[ -f "$CONFIG_FILE" ]]; then
  POC_ROOT=$(jq -r '.root // empty' "$CONFIG_FILE" 2>/dev/null | sed "s|^~|$HOME|")
  echo "Config found: $CONFIG_FILE"
else
  echo ""
  echo "No config found. Let's create one."
  echo ""
  read -p "POC root directory [$HOME/Dev/pocs]: " POC_ROOT_INPUT
  POC_ROOT="${POC_ROOT_INPUT:-$HOME/Dev/pocs}"
  POC_ROOT="${POC_ROOT/#\~/$HOME}"

  read -p "Vercel team/scope: " VERCEL_SCOPE
  read -p "Custom domain (e.g., example.com): " ALIAS_DOMAIN

  mkdir -p "$(dirname "$CONFIG_FILE")"
  cat > "$CONFIG_FILE" << EOF
{
  "root": "${POC_ROOT/#$HOME/~}",
  "vercelScope": "$VERCEL_SCOPE",
  "aliasDomain": "$ALIAS_DOMAIN"
}
EOF
  echo "Created: $CONFIG_FILE"
fi

POC_ROOT="${POC_ROOT:-$HOME/Dev/pocs}"
echo "POC root: $POC_ROOT"
echo ""

# Create POC_ROOT if needed
if [[ ! -d "$POC_ROOT" ]]; then
  echo "Creating POC root directory..."
  mkdir -p "$POC_ROOT"
fi

# Create project-level Claude settings
CLAUDE_SETTINGS_DIR="$POC_ROOT/.claude"
CLAUDE_SETTINGS_FILE="$CLAUDE_SETTINGS_DIR/settings.json"

echo "Setting up project-level hooks..."
mkdir -p "$CLAUDE_SETTINGS_DIR"

cat > "$CLAUDE_SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Write|Edit|mcp__granola__.*|mcp__supabase__.*|WebSearch",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/skills/poc/hooks/auto-approve.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/skills/poc/hooks/post-deploy-commit.sh"
          }
        ]
      }
    ]
  }
}
EOF

echo "Created: $CLAUDE_SETTINGS_FILE"

# Create/update settings.local.json with permissions
CLAUDE_LOCAL_FILE="$CLAUDE_SETTINGS_DIR/settings.local.json"
echo "Setting up permissions in settings.local.json..."

cat > "$CLAUDE_LOCAL_FILE" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(command -v *)",
      "Bash(* --version)",
      "Bash(which *)",
      "Bash(bun install*)",
      "Bash(bun dev*)",
      "Bash(bun run*)",
      "Bash(bun add*)",
      "Bash(vercel *)",
      "Bash(git status*)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git commit -m *)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git init*)",
      "Bash(git branch *)",
      "Bash(/*poc/scripts/*)",
      "Bash(~/.claude/skills/poc/scripts/*)",
      "Bash(source /*/load-config.sh)",
      "Bash(source /*)",
      "Bash(chmod +x *)",
      "Bash(mkdir -p *)",
      "mcp__granola__list_meetings",
      "mcp__granola__get_meetings",
      "mcp__granola__get_meeting_transcript",
      "mcp__granola__query_granola_meetings",
      "WebSearch",
      "WebFetch",
      "Read(~/.claude/skills/poc/*)",
      "Read(~/.claude/skills/poc/**/*)",
      "Write",
      "Edit"
    ]
  }
}
EOF

echo "Created: $CLAUDE_LOCAL_FILE"
echo ""

# Make hooks executable
chmod +x "$SKILL_DIR/hooks/"*.sh
chmod +x "$SKILL_DIR/scripts/"*.sh

echo ""
echo "Installation complete!"
echo ""
echo "Hooks will auto-apply when working in: $POC_ROOT"
echo ""
echo "Next: Open Claude Code and run /poc"
echo "      (First run will auto-configure plugins and Granola MCP)"
