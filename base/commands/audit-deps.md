---
name: audit-deps
description: "Audit project dependencies for unused, heavy, or vulnerable packages"
---

Audit the project's dependencies for issues.

## Steps

1. Find dependency manifests in the project: `package.json`, `requirements.txt`, `pyproject.toml`, or similar.
2. Launch the `dependency-auditor` agent with the manifest files and relevant source code.
3. Present the categorized findings to the user with actionable recommendations.
