# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-01-16

### Changed

- **Consolidated to Markdown-only**: Removed `ralphed-features.json` in favor of unified `IMPLEMENTATION_PLAN.md`
  - Features now defined directly in IMPLEMENTATION_PLAN.md with Markdown checkboxes (`- [ ]` / `- [x]`)
  - ~40-60% more token-efficient per [ghuntley's Ralph Wiggum recommendations](https://ghuntley.com/ralph/)
- `[OPUS]` tag on category headings replaces `"model": "opus"` JSON field
- Updated `PROMPT_build.md` to reference only IMPLEMENTATION_PLAN.md
- CLI auto-generation now outputs Markdown features directly
- Added CLAUDE.md for Claude Code guidance

### Removed

- `ralphed-features.json` - consolidated into IMPLEMENTATION_PLAN.md

## [2.0.0] - 2026-01-11

### Added

- **Dual-mode operation**: `--mode plan` for gap analysis, `--mode build` for implementation (default)
- **AGENTS.md**: Operational guide loaded each iteration (project conventions, learnings)
- **IMPLEMENTATION_PLAN.md**: Structured task tracking (completed/pending/discovered issues)
- **PROMPT_plan.md**: Instructions for planning mode - gap analysis only
- **PROMPT_build.md**: Instructions for building mode - implementation and validation
- **Git tags**: Creates tags on successful build iterations (`ralph-YYYYMMDD-HHMMSS`)
- **Type checking**: Added `TYPE_CMD` configuration for type validation
- **Topic scope guidance**: Documentation for single-concern feature descriptions
- Reference to official methodology: [github.com/ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum)

### Changed

- `ralphed.sh` completely rewritten for dual-mode support
- Prompt now includes `AGENTS.md`, `IMPLEMENTATION_PLAN.md`, and mode-specific instructions
- CLI setup now copies all new template files
- CLI next steps updated to recommend planning before building
- README extensively updated with new features and methodology alignment
- Auto-creates missing `AGENTS.md` and `IMPLEMENTATION_PLAN.md` on first run

### Fixed

- Better alignment with official Ralph Wiggum methodology

## [1.1.0] - 2025-01-06

### Added

- **Model switching**: Uses Sonnet by default, automatically falls back to Opus when needed
- `"model": "opus"` field in features JSON for marking complex features
- Self-escalation: Claude can output `<signal>NEEDS_OPUS</signal>` to trigger Opus
- Automatic retry with Opus when Sonnet fails (non-zero exit)
- Fallback count displayed in summary output
- Model configuration variables in `ralphed.sh` (`DEFAULT_MODEL`, `FALLBACK_MODEL`)
- CLI setup now includes model field guidance in auto-generation prompt
- Post-setup output shows model switching info

### Changed

- `ralphed.sh` now uses `--model` flag with configurable defaults
- Auto-generation prompt updated to include model field with usage guidelines
- CLI README updated with Model Switching section

## [1.0.0] - 2025-01-05

### Added

- Initial release
- Interactive CLI setup via `npx ralphed`
- Auto-generate features from PRD using Claude Code
- Bash execution loop with iteration-based workflow
- Progress tracking via `ralphed-features.json` and `progress.txt`
- Git commit after each completed feature
- Timestamped execution logs
- `<promise>COMPLETE</promise>` signal for completion detection
- Ctrl+C handling with summary output
