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
