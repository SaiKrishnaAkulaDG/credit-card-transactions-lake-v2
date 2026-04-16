#!/bin/bash
# tools/challenge.sh — PBVI challenge agent runner
# Invokes Claude Code with task context for manual verification

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Self-test mode: --check
if [ "$1" = "--check" ]; then
  echo "Challenge mode self-check..."
  [ -f "$REPO_ROOT/docs/Claude.md" ] || { echo "ERROR: docs/Claude.md missing"; exit 1; }
  [ -f "$REPO_ROOT/docs/EXECUTION_PLAN_v1.2.md" ] || { echo "ERROR: EXECUTION_PLAN_v1.2.md missing"; exit 1; }
  [ -f "$REPO_ROOT/PROJECT_MANIFEST.md" ] || { echo "ERROR: PROJECT_MANIFEST.md missing"; exit 1; }
  echo "OK: Challenge mode ready"
  exit 0
fi

# Challenge mode: tools/challenge.sh S[N] TASK_ID
if [ $# -lt 2 ]; then
  echo "Usage: $0 --check"
  echo "       $0 S[N] TASK_ID"
  exit 1
fi

SESSION="$1"
TASK_ID="$2"

echo "=== Challenge Mode: $SESSION Task $TASK_ID ==="
echo "Collecting context..."

# Show relevant documents
echo ""
echo "--- EXECUTION_PLAN.md (Task section) ---"
grep -A 50 "### Task $TASK_ID" "$REPO_ROOT/docs/EXECUTION_PLAN_v1.2.md" 2>/dev/null | head -40 || echo "(task section not found)"

# Show recent git diff
echo ""
echo "--- Git diff (recent changes) ---"
git diff HEAD~1 HEAD --stat 2>/dev/null || echo "(no prior commits)"

echo ""
echo "=== Ready for engineer challenge findings review ==="
