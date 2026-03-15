---
name: audit-deps
description: "Audit project dependencies for unused, heavy, or vulnerable packages"
---

Audit the project's dependencies for issues.

## Step 1: Find manifests

Search for dependency manifests:
- Node.js: `package.json`, `package-lock.json`, `bun.lock`
- Python: `requirements.txt`, `pyproject.toml`, `Pipfile`, `uv.lock`
- Rust: `Cargo.toml`
- Go: `go.mod`
- Ruby: `Gemfile`

Also run the native audit tool if available:
```bash
npm audit --json 2>/dev/null || pip audit --format=json 2>/dev/null || cargo audit --json 2>/dev/null || true
```

## Step 2: Analyze

Launch the `dependency-auditor` agent with:
- The manifest files
- The native audit output (if any)
- Key source directories (for import verification)

## Step 3: Present

Present findings ordered by actionability: unused (easy wins first), then security (most urgent), then heavy/duplicates/version.

Include a summary line: `Dependency Audit: N findings (X to remove, Y security, Z to replace)`

## Rules

- **Verify before flagging unused.** A package may be a CLI tool, Babel plugin, or implicit dependency. Check scripts, config files, and build tooling.
- **Don't flag dev deps for size.** Dev dependencies don't ship to production.
- **Recommend specific alternatives.** "Replace moment with Intl.DateTimeFormat" not "consider a lighter option."
- **Read-only.** Present findings — don't remove or modify dependencies without user confirmation.
