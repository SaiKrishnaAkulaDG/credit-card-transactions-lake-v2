#!/bin/bash
# tools/monitor.sh — Session progress monitor
# Shows current session log status and task completion count

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Session Progress Monitor ==="
echo ""

# List all session logs
echo "--- Session Logs ---"
for log in "$REPO_ROOT"/sessions/*_SESSION_LOG.md; do
  if [ -f "$log" ]; then
    session=$(basename "$log" _SESSION_LOG.md)
    lines=$(wc -l < "$log")
    echo "$session: $lines lines"
  fi
done

echo ""
echo "--- Verification Records ---"
for record in "$REPO_ROOT"/sessions/*_VERIFICATION_RECORD.md; do
  if [ -f "$record" ]; then
    session=$(basename "$record" _VERIFICATION_RECORD.md)
    lines=$(wc -l < "$record")
    echo "$session: $lines lines"
  fi
done

echo ""
echo "--- Repository Status ---"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Recent commits:"
git log --oneline | head -5

echo ""
echo "--- Data Layer Status ---"
for dir in bronze silver gold quarantine; do
  if [ -d "$REPO_ROOT/$dir" ]; then
    count=$(find "$REPO_ROOT/$dir" -name "*.parquet" 2>/dev/null | wc -l)
    echo "$dir/: $count parquet files"
  fi
done

echo ""
echo "=== End Monitor ==="
