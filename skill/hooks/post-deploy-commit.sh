#!/bin/bash
# Auto-commit after successful POC deployment
# PostToolUse hook for Bash tool

INPUT=$(cat)

# Only process Bash tool
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .tool // .name // empty' 2>/dev/null)
[[ "$TOOL_NAME" != "Bash" ]] && exit 0

# Check if it was a deploy script
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[[ "$COMMAND" != *"/poc/scripts/deploy.sh"* ]] && exit 0

# Check if it succeeded (exit code 0)
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result.exit_code // .exit_code // empty' 2>/dev/null)
[[ "$EXIT_CODE" != "0" && -n "$EXIT_CODE" ]] && exit 0

# Get the project directory from the command or cwd
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
if [[ -z "$PROJECT_DIR" ]]; then
  # Try to extract from command argument
  PROJECT_DIR=$(echo "$COMMAND" | grep -oE '[^ ]+$')
fi

[[ -z "$PROJECT_DIR" || ! -d "$PROJECT_DIR" ]] && exit 0

# Check if it's a git repo
cd "$PROJECT_DIR" || exit 0
[[ ! -d ".git" ]] && exit 0

# Check if there are changes to commit (mainly .vercel/)
if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
  # Extract URL from deploy output if available
  STDOUT=$(echo "$INPUT" | jq -r '.tool_result.stdout // empty' 2>/dev/null)
  LIVE_URL=$(echo "$STDOUT" | grep -oE 'https://[^ ]+' | tail -1)

  # Get client slug from package.json
  CLIENT_SLUG=$(jq -r '.name' package.json 2>/dev/null | sed 's/-poc$//')

  git add -A
  git commit -m "$(cat <<EOF
chore($CLIENT_SLUG): add vercel deployment config

Live at: ${LIVE_URL:-deployed}
EOF
)" 2>/dev/null

  # Output message for Claude to see
  echo '{"message":"Auto-committed deployment config"}'
fi
