#!/bin/bash
# Load POC configuration from file or environment variables
# Source this script: source <skill-dir>/scripts/load-config.sh

# Determine skill directory from this script's location
if [[ -n "${BASH_SOURCE[0]}" ]]; then
  POC_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  # Fallback: try common locations
  for dir in "$HOME/.claude/skills/poc" "$HOME/.agents/skills/poc"; do
    [[ -d "$dir" ]] && POC_SKILL_DIR="$dir" && break
  done
fi

CONFIG_FILE="$HOME/.config/poc/config.json"

if [[ -f "$CONFIG_FILE" ]]; then
  POC_ROOT=$(jq -r '.root // empty' "$CONFIG_FILE" | sed "s|^~|$HOME|")
  POC_VERCEL_SCOPE=$(jq -r '.vercelScope // empty' "$CONFIG_FILE")
  POC_ALIAS_DOMAIN=$(jq -r '.aliasDomain // empty' "$CONFIG_FILE")
fi

# Apply defaults / env var overrides
POC_ROOT="${POC_ROOT:-${POC_ROOT_ENV:-$HOME/Dev/pocs}}"
POC_VERCEL_SCOPE="${POC_VERCEL_SCOPE:-$POC_VERCEL_SCOPE_ENV}"
POC_ALIAS_DOMAIN="${POC_ALIAS_DOMAIN:-$POC_ALIAS_DOMAIN_ENV}"

# Validate required settings
if [[ -z "$POC_VERCEL_SCOPE" ]]; then
  echo "ERROR: POC_VERCEL_SCOPE not configured" >&2
  echo "Set in ~/.config/poc/config.json or POC_VERCEL_SCOPE env var" >&2
  return 1 2>/dev/null || exit 1
fi

if [[ -z "$POC_ALIAS_DOMAIN" ]]; then
  echo "ERROR: POC_ALIAS_DOMAIN not configured" >&2
  echo "Set in ~/.config/poc/config.json or POC_ALIAS_DOMAIN env var" >&2
  return 1 2>/dev/null || exit 1
fi

export POC_ROOT POC_VERCEL_SCOPE POC_ALIAS_DOMAIN POC_SKILL_DIR

echo "Config loaded:"
echo "  POC_SKILL_DIR=$POC_SKILL_DIR"
echo "  POC_ROOT=$POC_ROOT"
echo "  POC_VERCEL_SCOPE=$POC_VERCEL_SCOPE"
echo "  POC_ALIAS_DOMAIN=$POC_ALIAS_DOMAIN"
