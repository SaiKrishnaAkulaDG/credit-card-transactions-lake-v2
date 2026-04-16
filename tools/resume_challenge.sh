#!/bin/bash
# tools/resume_challenge.sh — Challenge findings resume
# Resumes after CHALLENGE FINDINGS handling

set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <session> <task_id>"
  echo "Example: $0 S1 1.2"
  exit 1
fi

SESSION="$1"
TASK_ID="$2"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VERIFICATION_RECORD="$REPO_ROOT/sessions/${SESSION}_VERIFICATION_RECORD.md"

echo "=== Resuming Challenge: $SESSION Task $TASK_ID ==="
echo ""

if [ -f "$VERIFICATION_RECORD" ]; then
  echo "--- Verification Record (last 40 lines) ---"
  tail -40 "$VERIFICATION_RECORD"
  echo ""
fi

echo "Task: $SESSION Task $TASK_ID"
echo "Status: Challenge findings processed — ready to resume"
echo ""
echo "To continue:"
echo "  1. Review findings above"
echo "  2. Invoke: claude code"
echo "  3. Reference: $SESSION Task $TASK_ID — resume after challenge"
