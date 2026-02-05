#!/bin/bash
# Build script - packages skill and creates standalone installer
# Run manually or via pre-commit hook

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$SCRIPT_DIR/skill"
OUT_DIR="$SCRIPT_DIR"

echo "Building POC skill..."

# Package the skill (creates poc.skill)
cd "$SKILL_DIR"
zip -r "$OUT_DIR/poc.skill" . -x "*.DS_Store"
echo "✓ Created poc.skill"

# Create standalone installer with embedded skill
cat > "$OUT_DIR/install-poc.sh" << 'SCRIPT_HEAD'
#!/bin/bash
# POC Skill Installer - Self-contained
# Run: curl -fsSL https://raw.githubusercontent.com/s-max/poc-skill/main/install-poc.sh | bash

set -e

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║       POC Skill Installer             ║"
echo "╚═══════════════════════════════════════╝"
echo ""

DEFAULT_SKILL_DIR="$HOME/.claude/skills/poc"

if [[ -t 0 ]]; then
  read -p "Install location [$DEFAULT_SKILL_DIR]: " SKILL_DIR
else
  SKILL_DIR=""
fi
SKILL_DIR="${SKILL_DIR:-$DEFAULT_SKILL_DIR}"
SKILL_DIR="${SKILL_DIR/#\~/$HOME}"

echo "Installing to: $SKILL_DIR"

if [[ -d "$SKILL_DIR" ]]; then
  if [[ -t 0 ]]; then
    read -p "Skill already exists. Overwrite? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
  fi
  rm -rf "$SKILL_DIR"
fi

mkdir -p "$(dirname "$SKILL_DIR")"

echo "Extracting skill files..."
SKILL_DATA=$(cat << 'SKILL_PAYLOAD'
SCRIPT_HEAD

# Embed base64-encoded skill
base64 -i "$OUT_DIR/poc.skill" >> "$OUT_DIR/install-poc.sh"

cat >> "$OUT_DIR/install-poc.sh" << 'SCRIPT_TAIL'
SKILL_PAYLOAD
)

echo "$SKILL_DATA" | base64 -d > /tmp/poc-skill-$$.zip
unzip -q /tmp/poc-skill-$$.zip -d "$SKILL_DIR"
rm /tmp/poc-skill-$$.zip

echo "✓ Skill files extracted"

chmod +x "$SKILL_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$SKILL_DIR/hooks/"*.sh 2>/dev/null || true

AGENTS_SKILLS="$HOME/.agents/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"

if [[ "$SKILL_DIR" == "$AGENTS_SKILLS/poc" ]] && [[ -d "$CLAUDE_SKILLS" ]]; then
  ln -sf "$SKILL_DIR" "$CLAUDE_SKILLS/poc" 2>/dev/null || true
elif [[ "$SKILL_DIR" == "$CLAUDE_SKILLS/poc" ]] && [[ -d "$AGENTS_SKILLS" ]]; then
  ln -sf "$SKILL_DIR" "$AGENTS_SKILLS/poc" 2>/dev/null || true
fi

echo ""
echo "Running skill setup..."
echo ""

bash "$SKILL_DIR/scripts/install.sh"

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║       Installation Complete!          ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Open Claude Code (or restart if already open)"
echo "  2. Run: /mcp"
echo "  3. Select Granola and authenticate in browser"
echo "  4. Try: /poc"
echo ""
SCRIPT_TAIL

chmod +x "$OUT_DIR/install-poc.sh"
echo "✓ Created install-poc.sh"

echo ""
echo "Build complete!"
