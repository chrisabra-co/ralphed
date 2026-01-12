# Building Mode Instructions

You are in BUILDING MODE. Implement features according to the plan.

## Your Task

1. **Study** `AGENTS.md` for operational guidelines
2. **Study** `IMPLEMENTATION_PLAN.md` to understand current state
3. **Study** `ralphed-features.json` for feature requirements
4. **Select** the highest-priority incomplete feature
5. **Study** relevant source code before making changes
6. **Implement** the feature fully - no stubs or partial implementations
7. **Validate** using the project's build, lint, and type check commands
8. **Update** `ralphed-features.json` marking the feature `"passes": true`
9. **Update** `IMPLEMENTATION_PLAN.md` with progress
10. **Append** notes to `progress.txt` for context
11. **Commit** with a descriptive message

## Rules

- Work on ONE feature per iteration only
- Do not assume something is not implemented - verify first
- Complete implementations fully, avoid stubs
- Document any discovered issues in `IMPLEMENTATION_PLAN.md`
- If validation fails, fix the issues before committing

## Model Escalation

If a feature has `"model": "opus"` or you determine the task is too complex:
<signal>NEEDS_OPUS</signal>

## Completion

If all features are complete, output:
<promise>COMPLETE</promise>
