#!/bin/bash
set -eo pipefail

# RALPHED - Ralph Wiggum Execution Pattern
# Iterative, single-feature autonomous development with Claude Code
#
# Prerequisites:
#   - Claude Code CLI installed and authenticated
#   - Run /sandbox in Claude Code first for bash auto-allow
#
# Usage: ./ralphed.sh <iterations>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  echo ""
  echo "Examples:"
  echo "  $0 1      # Single iteration"
  echo "  $0 10     # Run 10 iterations"
  echo "  $0 100    # Run until complete or 100 iterations"
  exit 1
fi

# Configuration - modify these as needed
FEATURES_FILE="$SCRIPT_DIR/ralphed-features.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/ralphed-$(date '+%Y%m%d-%H%M%S').log"
BUILD_CMD="npm run build"
LINT_CMD="npm run lint"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Setup
START_TIME=$(date +%s)
COMPLETED=0

show_summary() {
  local end_time=$(date +%s)
  local elapsed=$((end_time - START_TIME))
  local minutes=$((elapsed / 60))
  local seconds=$((elapsed % 60))
  echo ""
  echo "================================"
  echo "SUMMARY"
  echo "================================"
  echo "Iterations completed: $COMPLETED"
  echo "Total time: ${minutes}m ${seconds}s"
  echo "Log file: $LOG_FILE"
  echo "================================"
}

trap 'echo ""; echo "Interrupted!"; show_summary; exit 130' INT

echo "RALPHED - Ralph Wiggum Execution"
echo "Features: $FEATURES_FILE"
echo "Logging to: $LOG_FILE"
echo ""

for ((i=1; i<=$1; i++)); do
  echo "================================"
  echo "Iteration $i/$1 - $(date '+%H:%M:%S')"
  echo "================================"

  result=$(claude --permission-mode acceptEdits -p "@${FEATURES_FILE} @${PROGRESS_FILE} \
1. Find the highest-priority incomplete feature and work ONLY on that feature. \
Choose based on dependencies and what makes sense to build next. \
2. Implement the feature fully. \
3. Verify: ${BUILD_CMD} and ${LINT_CMD} pass. \
4. Update ralphed-features.json marking the feature as passes: true. \
5. Append progress notes to progress.txt for context. \
6. Make a git commit for this feature. \
ONLY WORK ON A SINGLE FEATURE PER ITERATION. \
If all features are complete, output <promise>COMPLETE</promise>." | tee /dev/tty | tee -a "$LOG_FILE") || {
    echo "ERROR: Claude failed on iteration $i"
    show_summary
    exit 1
  }

  COMPLETED=$i

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo "All features complete!"
    show_summary
    exit 0
  fi

  echo ""
done

echo "Completed $1 iterations"
show_summary
