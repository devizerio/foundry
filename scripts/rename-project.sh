#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: ./scripts/rename-project.sh <new-project-name>"
  echo "Example: ./scripts/rename-project.sh myapp"
  exit 1
fi

NEW_NAME="$1"
NEW_NAME_CAP="$(echo "${NEW_NAME:0:1}" | tr '[:lower:]' '[:upper:]')${NEW_NAME:1}"
NEW_SCOPE="@${NEW_NAME}"
OLD_SCOPE="@foundry"
OLD_NAME="foundry"

echo "🔄 Renaming project: ${OLD_NAME} → ${NEW_NAME}"
echo "   Scope: ${OLD_SCOPE} → ${NEW_SCOPE}"
echo ""

# Find and replace in all relevant files
# Package names in package.json files
find . -name 'package.json' -not -path '*/node_modules/*' -exec sed -i '' "s|${OLD_SCOPE}/|${NEW_SCOPE}/|g" {} +
find . -name 'package.json' -not -path '*/node_modules/*' -exec sed -i '' "s|\"name\": \"${OLD_NAME}\"|\"name\": \"${NEW_NAME}\"|g" {} +

# Config files — scope references (@foundry/ → @newname/)
find . \( -name '*.ts' -o -name '*.tsx' -o -name '*.mjs' -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.md' -o -name '*.mdx' -o -name '*.toml' -o -name '*.example' \) | \
  grep -v node_modules | grep -v .next | grep -v pnpm-lock | \
  xargs sed -i '' "s|${OLD_SCOPE}/|${NEW_SCOPE}/|g" 2>/dev/null || true

# Replace standalone "Foundry" (capitalized) in display strings
find . \( -name '*.ts' -o -name '*.tsx' -o -name '*.md' -o -name '*.json' -o -name '*.mdx' -o -name '*.example' \) | \
  grep -v node_modules | grep -v .next | grep -v pnpm-lock | \
  xargs sed -i '' "s|Foundry|${NEW_NAME_CAP}|g" 2>/dev/null || true

# Replace lowercase foundry in identifiers (yaml, toml, example configs, and CLAUDE.md)
find . \( -name '*.toml' -o -name '*.yaml' -o -name '*.yml' -o -name '*.example' -o -name 'CLAUDE.md' \) | \
  grep -v node_modules | \
  xargs sed -i '' "s|${OLD_NAME}|${NEW_NAME}|g" 2>/dev/null || true

echo "✅ Rename complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'pnpm install' to update the lockfile"
echo "  2. Verify: ./scripts/test-rename.sh"
echo "  3. Update README.md with your project details"
