#!/bin/bash
# tools/resume_session.sh — Blocked session resume
# Resumes from a BLOCKED stop point

set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <session> <task_id>"
  echo "Example: $0 S2 2.1"
  exit 1
fi

SESSION="$1"
TASK_ID="$2"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SESSION_LOG="$REPO_ROOT/sessions/${SESSION}_SESSION_LOG.md"

echo "=== Resuming $SESSION Task $TASK_ID ==="
echo ""

if [ -f "$SESSION_LOG" ]; then
  echo "--- Session Log (last 30 lines) ---"
  tail -30 "$SESSION_LOG"
  echo ""
fi

echo "Task: $SESSION Task $TASK_ID"
echo "Status: BLOCKED — awaiting engineer input"
echo ""
echo "To resume:"
echo "  1. Address the blocking issue"
echo "  2. Invoke: claude code"
echo "  3. Reference: $SESSION Task $TASK_ID — resume"
