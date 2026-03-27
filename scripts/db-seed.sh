#!/usr/bin/env bash
set -euo pipefail

echo "🌱 Seeding database..."
cd apps/supabase
supabase db reset --no-migrations=false
echo "✅ Seed complete"
