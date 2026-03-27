#!/usr/bin/env bash
set -euo pipefail

echo "🧪 Testing rename-project.sh..."

# Run the rename
./scripts/rename-project.sh testproject

# Check for leftover references
LEFTOVERS=$(grep -r "@foundry" --include='*.json' --include='*.ts' --include='*.tsx' --include='*.md' --include='*.yaml' --include='*.toml' . | grep -v node_modules | grep -v pnpm-lock || true)

if [ -n "$LEFTOVERS" ]; then
  echo "❌ Found leftover @foundry references:"
  echo "$LEFTOVERS"
  exit 1
else
  echo "✅ No leftover @foundry references found"
fi

# Reset back (user should use git checkout)
echo ""
echo "⚠️  Files were modified. Run 'git checkout .' to restore originals."
