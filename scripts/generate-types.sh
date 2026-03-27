#!/usr/bin/env bash
set -euo pipefail

echo "📝 Generating Supabase types..."
cd apps/supabase
npx supabase gen types typescript --local > ../../packages/shared/src/database.types.ts
echo "✅ Types written to packages/shared/src/database.types.ts"
