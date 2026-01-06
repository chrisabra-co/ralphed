# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
