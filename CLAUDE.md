# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RALPHED is a CLI tool that enables autonomous AI development using the "Ralph Wiggum method" - iterative, single-feature focused development with self-tracking progress. It orchestrates Claude Code to work through a feature list, completing one feature per iteration.

## Commands

```bash
# Run the CLI interactively (for end users)
npx ralphed

# Local development - run CLI directly
node plans/cli/bin/ralphed.js

# Execute the workflow (after setup)
./ralphed.sh [--mode plan|build] <iterations>
# e.g., ./ralphed.sh --mode plan 1    # Planning/gap analysis
# e.g., ./ralphed.sh 10               # Build 10 iterations
```

No build step required - this is a pure Node.js CLI with no compilation.

## Architecture

### CLI (`plans/cli/`)

- **bin/ralphed.js** - Interactive setup wizard using `prompts`. Creates project structure, optionally invokes Claude Code to auto-generate features from a PRD.
- **templates/** - Template files copied during setup:
  - `ralphed.sh` - Bash execution loop
  - `IMPLEMENTATION_PLAN.md` - Feature tracking with Markdown checkboxes
  - `AGENTS.md` - Operational guide
  - `PROMPT_plan.md` / `PROMPT_build.md` - Mode-specific instructions
  - `PRD.md` - Product requirements template

### Execution Loop (`ralphed.sh`)

The bash script runs Claude Code in a loop with `--permission-mode acceptEdits`:

1. Supports two modes: `plan` (gap analysis) and `build` (implementation)
2. Runs with `--model sonnet` by default (configurable via `DEFAULT_MODEL`)
3. Passes `@IMPLEMENTATION_PLAN.md`, `@AGENTS.md`, and `@progress.txt` as context
4. Claude picks next incomplete feature (unchecked tasks), implements it, verifies build/lint
5. Updates markdown (changes `[ ]` to `[x]`), appends to progress.txt, commits
6. Repeats until `<promise>COMPLETE</promise>` or iteration limit

**Model switching**: Automatically retries with Opus when:
- A category has `[OPUS]` tag
- Claude outputs `<signal>NEEDS_OPUS</signal>` (self-escalation)
- The iteration fails (non-zero exit)

### Data Files (created at runtime)

- **IMPLEMENTATION_PLAN.md** - Markdown file with categories, features, and checkbox tasks. Uses `[OPUS]` tag for complex features. More token-efficient than JSON (~40-60% smaller).
- **AGENTS.md** - Operational guide loaded each iteration (project conventions, learnings)
- **progress.txt** - Append-only log of completed work (provides context between iterations)
- **logs/** - Timestamped execution logs

## Dependencies

Minimal: `prompts` (interactive CLI) and `picocolors` (terminal colors). No framework, no build tools.
