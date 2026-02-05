#!/bin/bash
# Deploy POC to Vercel with custom domain and public access
# Usage: ./deploy.sh [project-dir]
# If no project-dir provided, uses current directory

set -e

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/load-config.sh"

# Ensure we're in a valid project
if [[ ! -f "package.json" ]]; then
  echo "ERROR: No package.json found in $PROJECT_DIR" >&2
  exit 1
fi

# Generate short ID for custom domain
SHORT_ID=$(head -c 100 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 6)

# Extract client slug from package.json name (assumes format: clientslug-poc)
CLIENT_SLUG=$(jq -r '.name' package.json | sed 's/-poc$//')

echo "Deploying POC..."
echo "  Project: $(pwd)"
echo "  Vercel scope: $POC_VERCEL_SCOPE"
echo "  Short ID: $SHORT_ID"
echo ""

# Install dependencies
echo "Installing dependencies..."
bun install

# Deploy to Vercel
echo "Deploying to Vercel..."
DEPLOY_URL=$(vercel --prod --yes --scope "$POC_VERCEL_SCOPE" 2>&1 | grep -E '^https://' | tail -1)
echo "Deployed: $DEPLOY_URL"

# Add custom domain
CUSTOM_DOMAIN="${CLIENT_SLUG}-${SHORT_ID}.${POC_ALIAS_DOMAIN}"
echo ""
echo "Adding custom domain: $CUSTOM_DOMAIN"
vercel domains add "$CUSTOM_DOMAIN" --scope "$POC_VERCEL_SCOPE" || {
  echo "WARNING: Failed to add custom domain. Using Vercel URL."
  CUSTOM_DOMAIN=""
}

# Disable deployment protection (make public)
echo ""
echo "Disabling deployment protection..."
if [[ -f ".vercel/project.json" ]]; then
  PROJECT_ID=$(jq -r '.projectId' .vercel/project.json)
  TEAM_ID=$(jq -r '.orgId' .vercel/project.json)
  VERCEL_TOKEN=$(jq -r '.token' ~/Library/Application\ Support/com.vercel.cli/auth.json 2>/dev/null || echo "")

  if [[ -n "$VERCEL_TOKEN" && -n "$PROJECT_ID" && -n "$TEAM_ID" ]]; then
    curl -s -X PATCH "https://api.vercel.com/v9/projects/$PROJECT_ID?teamId=$TEAM_ID" \
      -H "Authorization: Bearer $VERCEL_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"ssoProtection": null}' > /dev/null
    echo "Deployment protection disabled."
  else
    echo "WARNING: Could not disable deployment protection. Check manually."
  fi
else
  echo "WARNING: .vercel/project.json not found. Cannot disable protection."
fi

# Output summary
echo ""
echo "======================================"
echo "Deployment complete!"
echo "======================================"
if [[ -n "$CUSTOM_DOMAIN" ]]; then
  echo "Live URL: https://$CUSTOM_DOMAIN"
else
  echo "Live URL: $DEPLOY_URL"
fi
echo "Vercel URL: $DEPLOY_URL"
echo "Analytics: https://vercel.com/$POC_VERCEL_SCOPE/$(basename "$(pwd)")/analytics"
echo ""

# Output for easy copying
if [[ -n "$CUSTOM_DOMAIN" ]]; then
  echo "https://$CUSTOM_DOMAIN"
fi
