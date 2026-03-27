#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Foundry Setup"
echo "================"

# Check prerequisites
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required. Install via .tool-versions or nvm."; exit 1; }
command -v pnpm >/dev/null 2>&1 || { echo "❌ pnpm is required. Install: npm install -g pnpm"; exit 1; }

NODE_VERSION=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_VERSION" -lt 22 ]; then
  echo "❌ Node.js 22+ is required. Current: $(node -v)"
  exit 1
fi

echo "✅ Node.js $(node -v)"
echo "✅ pnpm $(pnpm -v)"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
pnpm install

# Check for Docker (needed for Supabase local dev)
if command -v docker >/dev/null 2>&1; then
  echo "✅ Docker found"

  # Start Supabase if not already running
  if command -v supabase >/dev/null 2>&1; then
    echo ""
    echo "🗄️  Starting Supabase..."
    cd apps/supabase
    supabase start || echo "⚠️  Supabase start failed. You may need to run 'supabase init' first."
    cd ../..

    # Generate types
    echo ""
    echo "📝 Generating database types..."
    ./scripts/generate-types.sh
  else
    echo "⚠️  Supabase CLI not found. Install: brew install supabase/tap/supabase"
  fi
else
  echo "⚠️  Docker not found. Supabase local dev requires Docker."
  echo "   Install Docker Desktop: https://docker.com/products/docker-desktop"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Copy .env.example files and fill in your values"
echo "  2. Run 'pnpm dev' to start development"
echo "  3. Open http://localhost:3000"
