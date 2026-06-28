{{STANDARDS}}

# Interaction Preferences

## Workflow Cycle

For non-trivial work, follow this sequence. Each step has a dedicated command:

1. **Plan** (`/plan`) — Architecture review, failure modes, test matrix, diagrams. Choose a mode: EXPAND (dream big), HOLD (make it bulletproof), or REDUCE (strip to essentials). Do NOT write code in this phase.
2. **Build** — Implement the plan. Use domain agents (nestjs-engineer, vue-engineer, etc.) for specialized work. Build in layers: domain first, then application, then infrastructure, then presentation.
3. **Review** (`/review`) — Three-reviewer pre-landing review (CRITICAL + DESIGN + INFORMATIONAL). Runs code-reviewer, security-auditor, and refactorer in parallel. Fix critical issues before shipping; DESIGN findings (elegance/simplicity) are suggested for one-click apply.
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
- When writing in Spanish, always use correct orthography: accents (á, é, í, ó, ú), ñ, ü, and proper punctuation (¿, ¡). Never omit diacritics.

## Code Discovery — prefer the knowledge graph over grep (if installed)

**Only if `codebase-memory-mcp` is installed** (binary on PATH or at `~/.local/bin/codebase-memory-mcp`, MCP server `codebase-memory-mcp` wired into the agent). If it is not installed, ignore this section — use `Grep`/`Glob`/`Read` as usual.

When it is available, prefer its MCP tools over `Grep`/`Glob`/file-by-file reading for **structural** code discovery — this applies to you AND to every sub-agent you spawn (Explore, code-reviewer, security-auditor, etc.); restate this preference in their prompts, since they don't inherit it automatically.

Priority for code questions (functions, classes, routes, callers, call chains, impact, dead code):
1. `search_graph` — find symbols by name/label/pattern
2. `trace_path` — who calls X / what X calls (call chains, data flow, cross-service)
3. `get_code_snippet` — exact symbol source by qualified name
4. `query_graph` — Cypher for complex patterns
5. `get_architecture` — high-level project map

Fall back to `Grep`/`Glob` freely for: string literals, error messages, config/non-code files, or when the repo isn't indexed yet (run `index_repository` first) or the graph returns too little. Always `Read` a file before editing it.
