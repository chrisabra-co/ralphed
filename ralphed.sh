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

# Model configuration
# - DEFAULT_MODEL: Used for most features (faster, cheaper)
# - FALLBACK_MODEL: Used when default fails or feature requires it
DEFAULT_MODEL="sonnet"
FALLBACK_MODEL="opus"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Setup
START_TIME=$(date +%s)
COMPLETED=0
FALLBACK_COUNT=0

# Build the prompt template
build_prompt() {
  echo "@${FEATURES_FILE} @${PROGRESS_FILE} \
1. Find the highest-priority incomplete feature and work ONLY on that feature. \
Choose based on dependencies and what makes sense to build next. \
If a feature has '\"model\": \"opus\"', it requires complex reasoning. \
2. Implement the feature fully. \
3. Verify: ${BUILD_CMD} and ${LINT_CMD} pass. \
4. Update ralphed-features.json marking the feature as passes: true. \
5. Append progress notes to progress.txt for context. \
6. Make a git commit for this feature. \
ONLY WORK ON A SINGLE FEATURE PER ITERATION. \
If all features are complete, output <promise>COMPLETE</promise>. \
If this feature is too complex for the current model, output <signal>NEEDS_OPUS</signal>."
}

# Run Claude with specified model, returns exit code
run_claude() {
  local model=$1
  local prompt
  prompt=$(build_prompt)

  echo "[Using model: $model]"
  claude --model "$model" --permission-mode acceptEdits -p "$prompt" 2>&1 | tee /dev/tty | tee -a "$LOG_FILE"
  return ${PIPESTATUS[0]}
}

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
  echo "Fallbacks to $FALLBACK_MODEL: $FALLBACK_COUNT"
  echo "Total time: ${minutes}m ${seconds}s"
  echo "Log file: $LOG_FILE"
  echo "================================"
}

trap 'echo ""; echo "Interrupted!"; show_summary; exit 130' INT

echo "RALPHED - Ralph Wiggum Execution"
echo "Features: $FEATURES_FILE"
echo "Models: $DEFAULT_MODEL (default) -> $FALLBACK_MODEL (fallback)"
echo "Logging to: $LOG_FILE"
echo ""

for ((i=1; i<=$1; i++)); do
  echo "================================"
  echo "Iteration $i/$1 - $(date '+%H:%M:%S')"
  echo "================================"

  # Try with default model first
  result=$(run_claude "$DEFAULT_MODEL") && exit_code=0 || exit_code=$?

  # Check if model signaled it needs Opus
  if [[ "$result" == *"<signal>NEEDS_OPUS</signal>"* ]]; then
    echo ""
    echo "[Feature requested $FALLBACK_MODEL - switching...]"
    result=$(run_claude "$FALLBACK_MODEL") && exit_code=0 || exit_code=$?
    ((FALLBACK_COUNT++))
  # Check if default model failed
  elif [[ $exit_code -ne 0 ]]; then
    echo ""
    echo "[${DEFAULT_MODEL} failed - retrying with ${FALLBACK_MODEL}...]"
    result=$(run_claude "$FALLBACK_MODEL") && exit_code=0 || exit_code=$?
    ((FALLBACK_COUNT++))

    if [[ $exit_code -ne 0 ]]; then
      echo "ERROR: Both models failed on iteration $i"
      show_summary
      exit 1
    fi
  fi

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
