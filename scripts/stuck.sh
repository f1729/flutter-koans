#!/usr/bin/env bash
# Shows where learners get stuck, from the anonymous events in D1.
# Usage: fnm exec --using=22 scripts/stuck.sh [days, default 30]
set -euo pipefail
cd "$(dirname "$0")/.."
DAYS="${1:-30}"
SINCE="strftime('%s','now') - $DAYS * 86400"
q() { npx --yes wrangler@latest d1 execute flutterkoans --remote --command "$1"; }
# Stored keys count koans from 0; show the 1-based path used in the app's URLs.
PAGE="rtrim(koan, '0123456789') || (CAST(substr(koan, length(rtrim(koan, '0123456789')) + 1) AS INTEGER) + 1)"

echo "== Koans with the most misses and reveals (last $DAYS days) =="
q "SELECT $PAGE AS page,
          SUM(outcome = 'wrong')  AS misses,
          SUM(outcome = 'reveal') AS reveals,
          SUM(outcome = 'solve')  AS solves,
          ROUND(AVG(CASE WHEN outcome = 'solve' THEN attempts END), 1) AS avg_misses
   FROM events WHERE at > $SINCE
   GROUP BY koan ORDER BY reveals DESC, misses DESC LIMIT 25"

echo "== Most common wrong answers: candidates for new Mistake entries =="
q "SELECT $PAGE AS page, answer, COUNT(*) AS times
   FROM events WHERE outcome = 'wrong' AND at > $SINCE
   GROUP BY koan, answer HAVING times > 1 ORDER BY times DESC LIMIT 40"
