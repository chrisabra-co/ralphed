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
2. Ask for your PRD or project outline document
3. Optionally auto-generate features from your PRD using Claude Code
4. Set up all the files you need

## What You Get

```
plans/
├── ralphed.sh              # Main execution script (Sonnet default, Opus fallback)
├── ralphed-features.json   # Feature list (auto-generated or template)
├── PRD.md                  # Your project requirements
├── logs/                   # Execution logs (gitignored)
└── .gitignore
```

## Model Switching

Uses Sonnet by default for speed/cost. Automatically switches to Opus when:
- A feature has `"model": "opus"` in the JSON
- Claude outputs `<signal>NEEDS_OPUS</signal>` (self-escalation)
- Sonnet fails on an iteration

## Usage

After setup, run:

```bash
cd plans
./ralphed.sh 10  # Run 10 iterations
```

## Requirements

- Node.js 18+
- [Claude Code CLI](https://claude.ai/code) (for auto-generation and execution)

## Credits

- [Ralph Wiggum Method](https://ghuntley.com/ralph/)
- [Video Demo by Matt Pocock](https://x.com/mattpocockuk/status/2008200878633931247)
- [Anthropic Engineering Blog](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

## License

MIT
