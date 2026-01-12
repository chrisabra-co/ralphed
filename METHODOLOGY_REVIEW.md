# Ralphed Plugin Review Against Official Ralph Wiggum Methodology

**Review Date**: 2026-01-11
**Official Source**: [github.com/ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum)

---

## Executive Summary

The Ralphed plugin captures the **core spirit** of the Ralph Wiggum technique (iterative single-task loops with backpressure), but differs significantly in implementation details. The official methodology is more structured with two distinct operational modes, a specs-based architecture, and stronger steering mechanisms.

| Aspect | Official Methodology | Ralphed Implementation | Status |
|--------|---------------------|------------------------|--------|
| Core Loop Pattern | Single task per iteration | Single feature per iteration | **Aligned** |
| Operational Modes | Planning + Building | Building only | **Gap** |
| Requirements | `specs/` directory (one file per topic) | Single `ralphed-features.json` | **Different** |
| Task Tracking | `IMPLEMENTATION_PLAN.md` | `progress.txt` (notes only) | **Gap** |
| Operational Guide | `AGENTS.md` | None | **Missing** |
| Backpressure | Tests, types, lints, builds | Build + lint only | **Partial** |
| Git Strategy | Commits + tags on success | Commits only | **Partial** |
| Parallel Subagents | Supported for certain work | Not implemented | **Missing** |
| Model Selection | Not specified | Sonnet/Opus fallback | **Enhancement** |
| CLI Installer | Not provided | `npx ralphed` | **Enhancement** |

---

## Detailed Analysis

### 1. What Ralphed Does Well

#### 1.1 Core Loop Pattern
The fundamental loop structure is correct. Both approaches:
- Process one task/feature per iteration
- Commit changes after each iteration
- Start with fresh context each loop
- Continue until completion or limit reached

#### 1.2 Backpressure Validation
Ralphed implements the critical "downstream" steering via build/lint checks:
```bash
BUILD_CMD="npm run build"
LINT_CMD="npm run lint"
```
This prevents drift and ensures quality gates.

#### 1.3 Model Switching (Enhancement)
Ralphed adds intelligent model switching not present in the official methodology:
- Sonnet as default (cost-effective)
- Self-escalation via `<signal>NEEDS_OPUS</signal>`
- Automatic fallback on failure

This is a **valuable addition** that optimizes cost while maintaining quality for complex features.

#### 1.4 NPX Installer (Enhancement)
The `npx ralphed` setup experience with auto-generation from PRDs is user-friendly and not present in the official methodology.

---

### 2. Gaps vs Official Methodology

#### 2.1 Missing: Planning Mode (Critical Gap)

**Official**: Two interchangeable prompts - `PROMPT_plan.md` and `PROMPT_build.md`
- **Planning Mode**: Gap analysis only, generates/updates implementation plan, no code changes
- **Building Mode**: Implementation focused

**Ralphed**: Only has building mode.

**Impact**: Without planning mode:
- Cannot course-correct when Ralph goes off track
- Cannot regenerate plans when specs change
- No structured way to do gap analysis

**Recommendation**: Add a `--mode plan` flag and `PROMPT_plan.md` that:
```bash
./ralphed.sh --mode plan    # Gap analysis only
./ralphed.sh --mode build   # Current behavior (default)
```

#### 2.2 Missing: IMPLEMENTATION_PLAN.md (Critical Gap)

**Official**: Persistent task list updated each iteration, used to:
- Track what's done vs remaining
- Prioritize next work
- Document discovered issues
- Enable plan regeneration

**Ralphed**: Uses `progress.txt` for notes only - not structured task tracking.

**Impact**:
- Harder for Ralph to understand overall progress
- No structured way to add discovered tasks
- Cannot regenerate from a plan state

**Recommendation**: Add `IMPLEMENTATION_PLAN.md` as structured task list:
```markdown
## Completed
- [x] Initialize project (commit abc123)

## In Progress
- [ ] Implement authentication

## Discovered Issues
- Need to handle rate limiting
```

#### 2.3 Missing: AGENTS.md (Important Gap)

**Official**: Operational guide loaded each iteration containing:
- Learned patterns and conventions
- Project-specific instructions
- Updated only with operational learnings
- Kept brief (context is precious)

**Ralphed**: No equivalent file.

**Impact**:
- No way to steer Ralph's behavior across iterations
- No place to capture project conventions
- Must rely solely on PRD for guidance

**Recommendation**: Add `AGENTS.md` template:
```markdown
# Operational Guide

## Project Conventions
- Use kebab-case for file names
- All API routes in /api directory

## Learnings
- Database migrations must run before tests
```

#### 2.4 Different: specs/ Directory vs Single JSON

**Official**: One specification file per "topic of concern" with scope test:
> A topic passes the scope test if describable in one sentence without conjunctions

**Ralphed**: Single `ralphed-features.json` with features that may have multiple concerns.

**Example Problem** (current template):
```json
{
  "description": "Implement user authentication with OAuth and session handling"
}
```
This is **three topics**: authentication, OAuth, sessions.

**Recommendation**: Either:
1. Add scope validation during feature generation
2. Or restructure to `specs/` directory:
```
specs/
├── 01-project-setup.md
├── 02-authentication.md
├── 03-oauth-integration.md
└── 04-session-management.md
```

#### 2.5 Missing: Git Tags

**Official**: Create git tags on successful builds for milestone tracking.

**Ralphed**: Only creates commits.

**Recommendation**: Add tagging after successful iterations:
```bash
git tag "ralph-$(date +%Y%m%d-%H%M%S)" -m "Completed: ${feature_description}"
```

#### 2.6 Missing: Parallel Subagents

**Official**: Uses parallel subagents for certain work types (information gathering, independent tasks).

**Ralphed**: Sequential single-agent execution only.

**Impact**: Potentially slower for tasks that could be parallelized.

**Recommendation**: Consider adding parallel execution for:
- Multiple independent code searches
- Gathering information from multiple files
- Running independent validations

#### 2.7 Partial: Backpressure Mechanisms

**Official**: Tests, type checks, lints, builds.

**Ralphed**: Build + lint only.

**Recommendation**: Expand to include type checking:
```bash
TYPE_CMD="npm run typecheck"  # or tsc --noEmit
```

---

### 3. Terminology & Conceptual Differences

#### 3.1 "Study" vs "Read"

**Official**: Uses "study" intentionally:
> "Study" encourages deeper analysis rather than surface-level reading

**Ralphed**: Prompt says "Find" rather than "Study":
```
1. Find the highest-priority incomplete feature...
```

**Recommendation**: Adopt "study" terminology:
```
1. Study the feature list and select the highest-priority incomplete feature...
```

#### 3.2 Context Window Awareness

**Official**: Explicitly addresses context management:
> ~176K truly usable tokens from 200K window, 40-60% being "smart zone"

**Ralphed**: No explicit context management guidance.

**Recommendation**: Add to AGENTS.md or prompt:
- Keep responses focused
- Don't repeat large code blocks unnecessarily
- Reference files by path rather than including content

---

### 4. Summary of Recommendations

#### High Priority (Significant Workflow Gaps)
1. **Add Planning Mode** - `PROMPT_plan.md` for gap analysis
2. **Add IMPLEMENTATION_PLAN.md** - Structured task tracking
3. **Add AGENTS.md** - Operational guide template

#### Medium Priority (Methodology Alignment)
4. **Add Topic Scope Validation** - Enforce single-concern features
5. **Expand Backpressure** - Add type checking
6. **Add Git Tags** - Tag successful iterations

#### Lower Priority (Nice to Have)
7. **Parallel Subagents** - For applicable work types
8. **"Study" Terminology** - Prompt wording alignment
9. **Context Guidelines** - Document token management

---

### 5. Unique Ralphed Strengths to Preserve

These Ralphed features are **valuable additions** not in the official methodology:

1. **Model Switching** - Sonnet/Opus fallback system
2. **Self-Escalation Signal** - `<signal>NEEDS_OPUS</signal>` pattern
3. **NPX Installer** - Easy project setup
4. **Auto Feature Generation** - PRD to features conversion
5. **Execution Logging** - Timestamped logs in `logs/`
6. **Summary Statistics** - Fallback count, timing

---

## Conclusion

Ralphed captures the essence of the Ralph Wiggum technique (iterative single-task loops) and adds valuable enhancements (model switching, CLI installer). However, it's missing key architectural elements from the official methodology:

1. **Dual-mode operation** (planning vs building)
2. **Structured implementation tracking** (IMPLEMENTATION_PLAN.md)
3. **Operational steering** (AGENTS.md)

Adding these would bring Ralphed into full alignment with the official methodology while retaining its unique enhancements.
