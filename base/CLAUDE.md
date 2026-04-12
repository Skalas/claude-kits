{{STANDARDS}}

# Interaction Preferences

## Workflow Cycle

For non-trivial work, follow this sequence. Each step has a dedicated command:

1. **Plan** (`/plan`) — Architecture review, failure modes, test matrix, diagrams. Choose a mode: EXPAND (dream big), HOLD (make it bulletproof), or REDUCE (strip to essentials). Do NOT write code in this phase.
2. **Build** — Implement the plan. Use domain agents (nestjs-engineer, vue-engineer, etc.) for specialized work. Build in layers: domain first, then application, then infrastructure, then presentation.
3. **Review** (`/review`) — Two-pass pre-landing review (CRITICAL + INFORMATIONAL). Runs code-reviewer and security-auditor agents in parallel. Fix critical issues before shipping.
4. **Ship** (`/ship`) — Automated pipeline: merge main, run tests, pre-landing review, bisectable commits, push, create PR.

For small changes (typos, config tweaks, simple fixes), skip straight to build and use `/commit` when done. The full cycle is for features, refactors, and anything touching multiple files.

## Working Approach

1. **Understand first** — Read existing code, understand the module structure, and identify established patterns before writing anything
2. **Design before building** — Outline architecture, data model, and API contracts before implementation
3. **Build in layers** — Domain first, then application, then infrastructure, then presentation
4. **Validate your work** — Verify the code compiles, imports resolve, schemas are valid, and tests pass
5. **Simplify** — After implementation, review for unnecessary complexity. Remove anything that doesn't serve the requirements

## Git Workflow

- Branch from `dev`, not `main`, unless explicitly told otherwise.
- PRs target `dev` by default.
- Use `main` only for production releases or when the project has no `dev` branch.

## Communication Style

- Be concise — explain decisions briefly, not exhaustively
- When trade-offs exist, state them and recommend the simpler option unless complexity is justified
- Flag potential issues proactively — don't wait to be asked
- If requirements are ambiguous, state your assumptions and proceed
