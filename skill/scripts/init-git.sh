#!/bin/bash
# Initialize git repository and create initial commit
# Usage: ./init-git.sh <project-dir> <client-slug> <concept-title> <poc-type> <feature1> [feature2] [feature3]

set -e

PROJECT_DIR="$1"
CLIENT_SLUG="$2"
CONCEPT_TITLE="$3"
POC_TYPE="$4"
shift 4
FEATURES=("$@")

if [[ -z "$PROJECT_DIR" || -z "$CLIENT_SLUG" || -z "$CONCEPT_TITLE" || -z "$POC_TYPE" ]]; then
  echo "Usage: $0 <project-dir> <client-slug> <concept-title> <poc-type> <feature1> [feature2] [feature3]" >&2
  exit 1
fi

# Change to project directory
cd "$PROJECT_DIR" || { echo "Failed to cd to $PROJECT_DIR" >&2; exit 1; }

# Build features list for commit message
FEATURES_TEXT=""
for feature in "${FEATURES[@]}"; do
  FEATURES_TEXT+="- $feature"$'\n'
done

git init
git add -A
git commit -m "$(cat <<EOF
feat($CLIENT_SLUG): initial POC scaffold

$CONCEPT_TITLE - $POC_TYPE

Key features:
$FEATURES_TEXT
EOF
)"

echo "Git initialized with initial commit."
