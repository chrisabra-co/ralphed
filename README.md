```
 ██████╗  █████╗ ██╗     ██████╗ ██╗  ██╗███████╗██████╗
 ██╔══██╗██╔══██╗██║     ██╔══██╗██║  ██║██╔════╝██╔══██╗
 ██████╔╝███████║██║     ██████╔╝███████║█████╗  ██║  ██║
 ██╔══██╗██╔══██║██║     ██╔═══╝ ██╔══██║██╔══╝  ██║  ██║
 ██║  ██║██║  ██║███████╗██║     ██║  ██║███████╗██████╔╝
 ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═════╝
```

[![npm version](https://img.shields.io/npm/v/ralphed.svg)](https://www.npmjs.com/package/ralphed)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=white)

A simple bash-based workflow for autonomous AI agent execution using Claude Code. Named after the Ralph Wiggum technique - iterative, single-feature focused development with self-tracking progress.

> "Me fail English? That's unpossible!" - Ralph Wiggum

## Credits

- **Ralph Wiggum Method**: [ghuntley.com/ralph](https://ghuntley.com/ralph/)
- **Official Methodology**: [github.com/ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum)
- **Video Demo**: [Matt Pocock on X](https://x.com/mattpocockuk/status/2008200878633931247)
- **Background**: [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Anthropic Engineering

## Quick Start

```bash
npx ralphed
```

The interactive setup will:
1. Ask for a project directory
2. Ask for your PRD or project outline
3. Optionally auto-generate features from your PRD using Claude Code
4. Set up all the files you need

Then run `/sandbox` in Claude Code and start building:

```bash
# First, run planning to analyze your project
./plans/ralphed.sh --mode plan 1

# Then build iteratively
./plans/ralphed.sh 10
```

## Overview

This pattern enables Claude Code to work through a feature list autonomously, completing one feature per iteration, updating progress, and committing changes. It's designed for:

- Building projects from PRDs
- Systematic feature implementation
- Self-documenting progress
- Hands-off development sessions

## Two Operational Modes

RALPHED supports two modes, following the official Ralph Wiggum methodology:

### Planning Mode

Gap analysis only - no code changes. Use this to:
- Establish or correct direction
- Update the implementation plan
- Analyze what's done vs remaining

```bash
./ralphed.sh --mode plan 1
```

### Building Mode (Default)

Implementation focused. Each iteration:
1. Studies requirements and the plan
2. Selects highest-priority incomplete feature
3. Implements the feature fully
4. Validates through build/lint/type checks
5. Updates tracking files and commits

```bash
./ralphed.sh 10
```

## How It Works

Each iteration, the script:

1. Passes context files to Claude Code (`AGENTS.md`, `IMPLEMENTATION_PLAN.md`, features, progress)
2. Claude selects the highest-priority incomplete feature
3. Implements the feature (build mode) or analyzes gaps (plan mode)
4. Runs build/lint checks (backpressure validation)
5. Updates `ralphed-features.json` and `IMPLEMENTATION_PLAN.md`
6. Appends notes to `progress.txt`
7. Creates a git commit and tag

The loop continues until all features are complete or the iteration limit is reached.

## Files

```
plans/
├── ralphed.sh              # Main execution script
├── ralphed-features.json   # Feature list with completion tracking
├── AGENTS.md               # Operational guide (loaded each iteration)
├── IMPLEMENTATION_PLAN.md  # Structured task tracking
├── PROMPT_plan.md          # Planning mode instructions
├── PROMPT_build.md         # Building mode instructions
├── PRD.md                  # Your project requirements document
├── progress.txt            # Auto-generated progress log (gitignored)
└── logs/                   # Execution logs (gitignored)
```

### Key Files Explained

| File | Purpose |
|------|---------|
| `AGENTS.md` | Operational guide loaded each iteration. Keep brief - contains project conventions and learnings. |
| `IMPLEMENTATION_PLAN.md` | Structured task tracking. Updated each iteration with completed/pending/discovered items. |
| `PROMPT_plan.md` | Instructions for planning mode - gap analysis only, no code changes. |
| `PROMPT_build.md` | Instructions for building mode - implementation, validation, commit. |

## Feature List Format

```json
{
  "project": "Your Project Name",
  "description": "Brief description",
  "features": [
    {
      "category": "setup",
      "description": "Initialize project with TypeScript",
      "steps": [
        "Step 1 description",
        "Step 2 description"
      ],
      "passes": false
    }
  ]
}
```

- **category**: Groups related features (setup, database, auth, etc.)
- **description**: What the feature accomplishes (single topic of concern)
- **steps**: Acceptance criteria / implementation steps
- **model**: (optional) Set to `"opus"` for complex features requiring advanced reasoning
- **passes**: Set to `true` when complete

### Topic Scope Test

Each feature should pass the scope test: describable in one sentence without conjunctions.

- "The color extraction system analyzes images to identify dominant colors"
- "Handle authentication, profiles, and billing" (three distinct topics - split these)

## Usage

```bash
# Run planning/gap analysis
./plans/ralphed.sh --mode plan 1

# Run N build iterations (one feature per iteration)
./plans/ralphed.sh 10

# Run a single build iteration
./plans/ralphed.sh 1

# Let it run until complete (set high number)
./plans/ralphed.sh 100
```

## Manual Setup

If you prefer to set up manually instead of using `npx ralphed`:

### 1. Prerequisites

- [Claude Code CLI](https://claude.ai/code) installed and authenticated
- Sandbox mode enabled: run `/sandbox` in Claude Code first

### 2. Setup

```bash
# Clone or copy template files to your project
git clone https://github.com/chrisabra-co/ralphed.git
cp -r ralphed/plans/ your-project/plans/

# Edit the feature list for your project
vim plans/ralphed-features.json

# Create or edit your PRD
vim plans/PRD.md
```

### 3. Run

```bash
./plans/ralphed.sh --mode plan 1   # Plan first
./plans/ralphed.sh 10              # Then build
```

## Customization

### Modify the Prompts

Edit `PROMPT_plan.md` or `PROMPT_build.md` to change the instructions given to Claude.

### Add Operational Learnings

Edit `AGENTS.md` to add project conventions, patterns, and learnings that should guide every iteration.

### Change Permission Mode

- `acceptEdits` - Auto-approve file edits (recommended)
- `plan` - Require approval for each action
- See Claude Code docs for all modes

### Configure Validation Commands

Edit `ralphed.sh` to change validation commands:

```bash
BUILD_CMD="npm run build"
LINT_CMD="npm run lint"
TYPE_CMD="npm run typecheck"
```

### Enable/Disable Git Tags

```bash
ENABLE_TAGS=true   # Create tags on successful iterations
ENABLE_TAGS=false  # Commits only
```

## Model Switching

RALPHED uses Sonnet by default and automatically falls back to Opus when needed. This saves tokens while ensuring complex features get the reasoning power they need.

### How It Works

1. **Default**: All features run with Sonnet (faster, cheaper)
2. **Feature-level hint**: Add `"model": "opus"` to complex features
3. **Self-escalation**: Claude can output `<signal>NEEDS_OPUS</signal>` if it determines the task is too complex
4. **Failure fallback**: If Sonnet fails, the iteration automatically retries with Opus

### Configuration

Edit the model settings in `ralphed.sh`:

```bash
DEFAULT_MODEL="sonnet"    # Used for most features
FALLBACK_MODEL="opus"     # Used when default fails or feature requires it
```

### When to Mark Features as Opus

Use `"model": "opus"` for:
- Complex authentication flows (OAuth, multi-provider)
- Intricate state management logic
- Features with many edge cases
- Cross-cutting architectural changes

The summary at the end shows how many iterations required fallback:

```
================================
SUMMARY
================================
Mode: build
Iterations completed: 10
Fallbacks to opus: 2
Total time: 25m 12s
================================
```

## Tips

- **Plan first**: Run `--mode plan` to establish direction before building
- **Start small**: Test with 1-2 iterations before long runs
- **Review commits**: Check git log periodically during long sessions
- **Interrupt safely**: Ctrl+C shows a summary and exits cleanly
- **Check logs**: Logs are timestamped in `plans/logs/`
- **Keep AGENTS.md brief**: Context is precious - only essential learnings

## Stopping Conditions

The script stops when:
- All features are complete (outputs `<promise>COMPLETE</promise>`)
- Iteration limit reached
- Claude encounters an error
- User interrupts with Ctrl+C

## Example Session

```
$ ./plans/ralphed.sh --mode plan 1

RALPHED - Ralph Wiggum Execution
Mode: plan
Features: /path/to/plans/ralphed-features.json
Plan: /path/to/plans/IMPLEMENTATION_PLAN.md
Logging to: /path/to/plans/logs/ralphed-20240115-143022.log

================================
Iteration 1/1 - 14:30:22
================================
[Mode: plan | Model: sonnet]
[Analyzing features and codebase...]
[Updated IMPLEMENTATION_PLAN.md]

Planning complete! Review IMPLEMENTATION_PLAN.md

$ ./plans/ralphed.sh 5

RALPHED - Ralph Wiggum Execution
Mode: build
Features: /path/to/plans/ralphed-features.json
Plan: /path/to/plans/IMPLEMENTATION_PLAN.md
Models: sonnet (default) -> opus (fallback)
Logging to: /path/to/plans/logs/ralphed-20240115-143122.log

================================
Iteration 1/5 - 14:31:22
================================
[Mode: build | Model: sonnet]
[Claude working on: Initialize Next.js project...]
[Commits: "feat: initialize Next.js with TypeScript"]

================================
Iteration 2/5 - 14:33:15
================================
[Mode: build | Model: sonnet]
[Claude working on: Configure Tailwind CSS...]
[Commits: "feat: configure Tailwind CSS and shadcn/ui"]

...

================================
SUMMARY
================================
Mode: build
Iterations completed: 5
Fallbacks to opus: 0
Total time: 12m 34s
Log file: /path/to/plans/logs/ralphed-20240115-143122.log
================================
```

## License

MIT - Use however you like.
