#!/usr/bin/env bash
set -euo pipefail

# Populate .env files from 1Password using .env.tpl templates.
# Requires: 1Password CLI (op) — https://developer.1password.com/docs/cli/get-started

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Check that op is installed
if ! command -v op &>/dev/null; then
  echo "Error: 1Password CLI (op) is not installed."
  echo "Install it: https://developer.1password.com/docs/cli/get-started"
  exit 1
fi

# Check that the user is signed in
if ! op account list &>/dev/null 2>&1; then
  echo "Error: Not signed in to 1Password CLI."
  echo "Run: op signin"
  exit 1
fi

echo "Populating env files from 1Password..."

# Web app: .env.tpl → .env.local
if [ -f "$ROOT_DIR/apps/web/.env.tpl" ]; then
  op inject -i "$ROOT_DIR/apps/web/.env.tpl" -o "$ROOT_DIR/apps/web/.env.local" --force
  echo "  ✓ apps/web/.env.local"
fi

# Server app: .env.tpl → .env
if [ -f "$ROOT_DIR/apps/server/.env.tpl" ]; then
  op inject -i "$ROOT_DIR/apps/server/.env.tpl" -o "$ROOT_DIR/apps/server/.env" --force
  echo "  ✓ apps/server/.env"
fi

echo ""
echo "Done! All env files populated from 1Password."
