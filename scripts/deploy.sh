#!/usr/bin/env bash
# Builds the web app and deploys it to Cloudflare Pages (https://flutterkoans.pages.dev).
# Wrangler needs Node 22+; with fnm, run: fnm exec --using=22 scripts/deploy.sh
set -euo pipefail
cd "$(dirname "$0")/.."

flutter test
flutter build web --release
npx --yes wrangler@latest pages deploy --branch main --commit-dirty=true
