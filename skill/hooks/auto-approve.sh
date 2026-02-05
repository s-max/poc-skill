#!/bin/bash
# Auto-approve operations for POC workflow
# Reads POC_ROOT from ~/.config/poc/config.json

INPUT=$(cat)

# Load POC_ROOT from config or use default
CONFIG_FILE="$HOME/.config/poc/config.json"
if [[ -f "$CONFIG_FILE" ]]; then
  POC_ROOT=$(jq -r '.root // empty' "$CONFIG_FILE" 2>/dev/null | sed "s|^~|$HOME|")
fi
POC_ROOT="${POC_ROOT:-$HOME/Dev/pocs}"

# Parse JSON fields
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .tool // .name // empty' 2>/dev/null)
get_field() { echo "$INPUT" | jq -r ".$1 // empty" 2>/dev/null; }

# Auto-approve Bash commands
if [[ "$TOOL_NAME" == "Bash" ]]; then
  COMMAND=$(get_field "tool_input.command")
  COMMAND_EXPANDED="${COMMAND/#\~/$HOME}"
  CWD=$(get_field "cwd")

  # POC skill scripts
  if [[ "$COMMAND" == *"/poc/scripts/"* ]] || [[ "$COMMAND_EXPANDED" == *"/poc/scripts/"* ]]; then
    echo '{"decision":"allow"}'; exit 0
  fi

  # Commands targeting POC directory
  if [[ "$COMMAND_EXPANDED" == *"$POC_ROOT"* ]] || [[ "$CWD" == "$POC_ROOT"* ]]; then
    echo '{"decision":"allow"}'; exit 0
  fi

  # Build/deploy tools
  if [[ "$COMMAND" == "bun "* ]] || [[ "$COMMAND" == "vercel "* ]]; then
    echo '{"decision":"allow"}'; exit 0
  fi

  # Prerequisite checks (read-only commands)
  if [[ "$COMMAND" == *"command -v"* ]] || \
     [[ "$COMMAND" == *"--version"* ]] || \
     [[ "$COMMAND" == "which "* ]]; then
    echo '{"decision":"allow"}'; exit 0
  fi
fi

# Auto-approve Write/Edit in POC directory
if [[ "$TOOL_NAME" == "Write" ]] || [[ "$TOOL_NAME" == "Edit" ]]; then
  FILE_PATH=$(get_field "tool_input.file_path")
  FILE_PATH="${FILE_PATH/#\~/$HOME}"
  if [[ "$FILE_PATH" == "$POC_ROOT"* ]]; then
    echo '{"decision":"allow"}'; exit 0
  fi
fi

# Auto-approve MCP tools used in POC workflow
if [[ "$TOOL_NAME" =~ ^mcp__granola__ ]] || \
   [[ "$TOOL_NAME" =~ ^mcp__supabase__ ]] || \
   [[ "$TOOL_NAME" == "WebSearch" ]]; then
  echo '{"decision":"allow"}'; exit 0
fi

# No decision - prompt user
