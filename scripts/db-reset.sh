#!/usr/bin/env bash
set -euo pipefail

echo "🗄️  Resetting database..."
cd apps/supabase
supabase db reset
cd ../..

echo "📝 Regenerating types..."
./scripts/generate-types.sh

echo "✅ Database reset complete"
