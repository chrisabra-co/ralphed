```
 ██████╗  █████╗ ██╗     ██████╗ ██╗  ██╗███████╗██████╗
 ██╔══██╗██╔══██╗██║     ██╔══██╗██║  ██║██╔════╝██╔══██╗
 ██████╔╝███████║██║     ██████╔╝███████║█████╗  ██║  ██║
 ██╔══██╗██╔══██║██║     ██╔═══╝ ██╔══██║██╔══╝  ██║  ██║
 ██║  ██║██║  ██║███████╗██║     ██║  ██║███████╗██████╔╝
 ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═════╝
```

Autonomous AI agent workflow for Claude Code using the Ralph Wiggum method.

## Quick Start

```bash
npx ralphed
```

This will:
1. Ask for a project directory (default: `./plans`)
2. Ask for your PRD — can be a **single file or a folder** of documents
3. Optionally auto-generate features from your PRD using Claude Code
4. Set up all the files you need

## What You Get

```
plans/
├── ralphed.sh              # Main execution script
├── IMPLEMENTATION_PLAN.md  # Feature list with checkboxes (auto-generated or template)
├── AGENTS.md               # Operational guide (project conventions)
├── PROMPT_plan.md          # Planning mode instructions
├── PROMPT_build.md         # Building mode instructions
├── PRD.md                  # Your project requirements
├── logs/                   # Execution logs (gitignored)
└── .gitignore
```

## Model Switching

Uses Sonnet by default for speed/cost. Automatically switches to Opus when:
- A category has `[OPUS]` tag in the markdown
- Claude outputs `<signal>NEEDS_OPUS</signal>` (self-escalation)
- Sonnet fails on an iteration

## Usage

After setup, run:

```bash
cd plans
./ralphed.sh --mode plan 1  # Optional: analyze and update plan
./ralphed.sh 10             # Run 10 build iterations
```

## Requirements

- Node.js 18+
- [Claude Code CLI](https://claude.ai/code) (for auto-generation and execution)

## Credits

- [Ralph Wiggum Method](https://ghuntley.com/ralph/)
- [Official Methodology](https://github.com/ghuntley/how-to-ralph-wiggum)
- [Video Demo by Matt Pocock](https://x.com/mattpocockuk/status/2008200878633931247)
- [Anthropic Engineering Blog](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

## License

MIT
