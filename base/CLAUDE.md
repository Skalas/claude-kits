# Interaction Preferences

## Working Approach

1. **Understand first** — Read existing code, understand the module structure, and identify established patterns before writing anything
2. **Design before building** — Outline architecture, data model, and API contracts before implementation
3. **Build in layers** — Domain first, then application, then infrastructure, then presentation
4. **Validate your work** — Verify the code compiles, imports resolve, schemas are valid, and tests pass
5. **Simplify** — After implementation, review for unnecessary complexity. Remove anything that doesn't serve the requirements

## Communication Style

- Be concise — explain decisions briefly, not exhaustively
- When trade-offs exist, state them and recommend the simpler option unless complexity is justified
- Flag potential issues proactively — don't wait to be asked
- If requirements are ambiguous, state your assumptions and proceed

## Development Environment

- When scaffolding or setting up a project, check that the appropriate LSP server for the project's language is installed. If not, install it as part of the dev environment setup.
- LSP servers enable instant code navigation (go-to-definition, find-references, call hierarchy) and catch type errors immediately after edits.
- Use the LSP tool for code navigation when available — prefer it over grep-based searching for finding definitions, references, and call hierarchies.
