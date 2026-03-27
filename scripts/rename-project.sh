#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: ./scripts/rename-project.sh <new-project-name>"
  echo "Example: ./scripts/rename-project.sh myapp"
  exit 1
fi

NEW_NAME="$1"
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

# Config files
find . -name '*.ts' -o -name '*.tsx' -o -name '*.mjs' -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.md' -o -name '*.toml' | \
  grep -v node_modules | grep -v .next | grep -v pnpm-lock | \
  xargs sed -i '' "s|${OLD_SCOPE}/|${NEW_SCOPE}/|g" 2>/dev/null || true

# Replace standalone "Foundry" (capitalized) in display strings
find . -name '*.ts' -o -name '*.tsx' -o -name '*.md' -o -name '*.json' -o -name '*.mdx' | \
  grep -v node_modules | grep -v .next | grep -v pnpm-lock | \
  xargs sed -i '' "s|Foundry|${NEW_NAME^}|g" 2>/dev/null || true

# Replace lowercase foundry in identifiers
find . -name '*.toml' -o -name '*.yaml' -o -name '*.yml' | \
  grep -v node_modules | \
  xargs sed -i '' "s|${OLD_NAME}|${NEW_NAME}|g" 2>/dev/null || true

echo "✅ Rename complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'pnpm install' to update the lockfile"
echo "  2. Verify: grep -r '${OLD_SCOPE}' --include='*.json' --include='*.ts' --include='*.tsx' . | grep -v node_modules"
echo "  3. Update README.md with your project details"
