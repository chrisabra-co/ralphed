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
./plans/ralphed.sh 10
```

## Overview

This pattern enables Claude Code to work through a feature list autonomously, completing one feature per iteration, updating progress, and committing changes. It's designed for:

- Building projects from PRDs
- Systematic feature implementation
- Self-documenting progress
- Hands-off development sessions

## How It Works

Each iteration, the script:

1. Passes the feature list and progress file to Claude Code
2. Claude selects the highest-priority incomplete feature
3. Implements the feature
4. Runs build/lint checks
5. Updates `ralphed-features.json` marking the feature complete
6. Appends notes to `progress.txt`
7. Creates a git commit

The loop continues until all features are complete or the iteration limit is reached.

## Files

```
plans/
├── ralphed.sh              # Main execution script
├── ralphed-features.json   # Feature list with completion tracking
├── PRD.md                  # Your project requirements document
├── progress.txt            # Auto-generated progress log (gitignored)
└── logs/                   # Execution logs (gitignored)
```

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
- **description**: What the feature accomplishes
- **steps**: Acceptance criteria / implementation steps
- **passes**: Set to `true` when complete

## Usage

```bash
# Run N iterations (one feature per iteration)
./plans/ralphed.sh 10

# Run a single iteration
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
./plans/ralphed.sh 10
```

## Customization

### Modify the Prompt

Edit `ralphed.sh` to change the instructions given to Claude:

```bash
claude --permission-mode acceptEdits -p "@plans/ralphed-features.json @plans/progress.txt \
Your custom instructions here..."
```

### Change Permission Mode

- `acceptEdits` - Auto-approve file edits (recommended)
- `plan` - Require approval for each action
- See Claude Code docs for all modes

### Add Context Files

Include additional files in the prompt:

```bash
claude -p "@plans/ralphed-features.json @plans/progress.txt @src/types.ts \
..."
```

## Tips

- **Start small**: Test with 1-2 iterations before long runs
- **Review commits**: Check git log periodically during long sessions
- **Interrupt safely**: Ctrl+C shows a summary and exits cleanly
- **Check logs**: Logs are timestamped in `plans/logs/`

## Stopping Conditions

The script stops when:
- All features are complete (outputs `<promise>COMPLETE</promise>`)
- Iteration limit reached
- Claude encounters an error
- User interrupts with Ctrl+C

## Example Session

```
$ ./plans/ralphed.sh 5

RALPHED - Ralph Wiggum Execution
Features: /path/to/plans/ralphed-features.json
Logging to: /path/to/plans/logs/ralphed-20240115-143022.log

================================
Iteration 1/5 - 14:30:22
================================
[Claude working on: Initialize Next.js project...]
[Commits: "feat: initialize Next.js with TypeScript"]

================================
Iteration 2/5 - 14:32:15
================================
[Claude working on: Configure Tailwind CSS...]
[Commits: "feat: configure Tailwind CSS and shadcn/ui"]

...

================================
SUMMARY
================================
Iterations completed: 5
Total time: 12m 34s
Log file: /path/to/plans/logs/ralphed-20240115-143022.log
================================
```

## License

MIT - Use however you like.
