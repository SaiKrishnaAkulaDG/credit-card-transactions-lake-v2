#!/bin/bash
# tools/launch.sh — Autonomous session launcher
# Invokes Claude Code with the session execution prompt

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <session_number>"
  echo "Example: $0 S1"
  exit 1
fi

SESSION="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PROMPT_FILE="$REPO_ROOT/sessions/${SESSION}_execution_prompt.md"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERROR: $PROMPT_FILE not found"
  exit 1
fi

echo "=== Launching $SESSION ==="
echo "Execution prompt: $PROMPT_FILE"
echo ""
echo "Starting Claude Code session..."
echo "Invoke: claude code"
echo "Then paste the content from: $PROMPT_FILE"
echo ""
cat "$PROMPT_FILE" | head -20
echo "..."
