#!/bin/bash
set -eo pipefail

# RALPHED - Ralph Wiggum Execution Pattern
# Iterative, single-feature autonomous development with Claude Code
#
# Prerequisites:
#   - Claude Code CLI installed and authenticated
#   - Run /sandbox in Claude Code first for bash auto-allow
#
# Usage: ./ralphed.sh [--mode plan|build] <iterations>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
MODE="build"
ITERATIONS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --mode)
      MODE="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      ITERATIONS="$1"
      shift
      ;;
  esac
done

if [ -z "$ITERATIONS" ]; then
  echo "Usage: $0 [--mode plan|build] <iterations>"
  echo ""
  echo "Modes:"
  echo "  plan   - Gap analysis only, updates IMPLEMENTATION_PLAN.md"
  echo "  build  - Implementation mode (default)"
  echo ""
  echo "Examples:"
  echo "  $0 1              # Single build iteration"
  echo "  $0 --mode plan 1  # Run planning/gap analysis"
  echo "  $0 10             # Run 10 build iterations"
  echo "  $0 100            # Run until complete or 100 iterations"
  exit 1
fi

if [[ "$MODE" != "plan" && "$MODE" != "build" ]]; then
  echo "Error: Mode must be 'plan' or 'build'"
  exit 1
fi

# Configuration - modify these as needed
FEATURES_FILE="$SCRIPT_DIR/ralphed-features.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
AGENTS_FILE="$SCRIPT_DIR/AGENTS.md"
PLAN_FILE="$SCRIPT_DIR/IMPLEMENTATION_PLAN.md"
PROMPT_FILE="$SCRIPT_DIR/PROMPT_${MODE}.md"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/ralphed-$(date '+%Y%m%d-%H%M%S').log"

# Validation commands
BUILD_CMD="npm run build"
LINT_CMD="npm run lint"
TYPE_CMD="npm run typecheck"

# Model configuration
# - DEFAULT_MODEL: Used for most features (faster, cheaper)
# - FALLBACK_MODEL: Used when default fails or feature requires it
DEFAULT_MODEL="sonnet"
FALLBACK_MODEL="opus"

# Git tagging
ENABLE_TAGS=true

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Ensure required files exist
touch "$PROGRESS_FILE"
if [ ! -f "$AGENTS_FILE" ]; then
  echo "Warning: $AGENTS_FILE not found. Creating default."
  cat > "$AGENTS_FILE" << 'AGENTS_EOF'
# Operational Guide

## Project Conventions
- Follow existing code patterns
- Use consistent naming conventions

## Validation
- Build, lint, and type check must pass before committing

## Learnings
<!-- Add project-specific learnings here -->
AGENTS_EOF
fi

if [ ! -f "$PLAN_FILE" ]; then
  echo "Warning: $PLAN_FILE not found. Creating default."
  cat > "$PLAN_FILE" << 'PLAN_EOF'
# Implementation Plan

## Completed

## In Progress

## Pending

## Discovered Issues

## Notes
PLAN_EOF
fi

# Setup
START_TIME=$(date +%s)
COMPLETED=0
FALLBACK_COUNT=0
LAST_FEATURE=""

# Build the prompt with context files
build_prompt() {
  local prompt_content=""
  if [ -f "$PROMPT_FILE" ]; then
    prompt_content=$(cat "$PROMPT_FILE")
  else
    # Fallback if prompt file doesn't exist
    if [ "$MODE" = "plan" ]; then
      prompt_content="Study the features and codebase. Update IMPLEMENTATION_PLAN.md with gap analysis. DO NOT implement code."
    else
      prompt_content="Find highest-priority incomplete feature. Implement it fully. Validate with build/lint. Update tracking files. Commit."
    fi
  fi

  echo "@${FEATURES_FILE} @${AGENTS_FILE} @${PLAN_FILE} @${PROGRESS_FILE} ${prompt_content}"
}

# Run Claude with specified model, returns exit code
run_claude() {
  local model=$1
  local prompt
  prompt=$(build_prompt)

  echo "[Mode: $MODE | Model: $model]"
  claude --model "$model" --permission-mode acceptEdits -p "$prompt" 2>&1 | tee /dev/tty | tee -a "$LOG_FILE"
  return ${PIPESTATUS[0]}
}

# Create git tag for successful iteration
create_tag() {
  if [ "$ENABLE_TAGS" = true ] && [ "$MODE" = "build" ]; then
    local tag_name="ralph-$(date '+%Y%m%d-%H%M%S')"
    git tag "$tag_name" -m "Ralphed iteration $COMPLETED complete" 2>/dev/null || true
  fi
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
  echo "Mode: $MODE"
  echo "Iterations completed: $COMPLETED"
  if [ "$MODE" = "build" ]; then
    echo "Fallbacks to $FALLBACK_MODEL: $FALLBACK_COUNT"
  fi
  echo "Total time: ${minutes}m ${seconds}s"
  echo "Log file: $LOG_FILE"
  echo "================================"
}

trap 'echo ""; echo "Interrupted!"; show_summary; exit 130' INT

echo "RALPHED - Ralph Wiggum Execution"
echo "Mode: $MODE"
echo "Features: $FEATURES_FILE"
echo "Plan: $PLAN_FILE"
if [ "$MODE" = "build" ]; then
  echo "Models: $DEFAULT_MODEL (default) -> $FALLBACK_MODEL (fallback)"
fi
echo "Logging to: $LOG_FILE"
echo ""

for ((i=1; i<=$ITERATIONS; i++)); do
  echo "================================"
  echo "Iteration $i/$ITERATIONS - $(date '+%H:%M:%S')"
  echo "================================"

  # Try with default model first
  result=$(run_claude "$DEFAULT_MODEL") && exit_code=0 || exit_code=$?

  # Check if model signaled it needs Opus (build mode only)
  if [[ "$MODE" = "build" && "$result" == *"<signal>NEEDS_OPUS</signal>"* ]]; then
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

  # Create tag on successful build iteration
  if [ "$MODE" = "build" ]; then
    create_tag
  fi

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    if [ "$MODE" = "plan" ]; then
      echo "Planning complete! Review IMPLEMENTATION_PLAN.md"
    else
      echo "All features complete!"
    fi
    show_summary
    exit 0
  fi

  echo ""
done

echo "Completed $ITERATIONS iterations"
show_summary
