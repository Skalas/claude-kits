---
name: refactor
description: "Identify refactoring opportunities in a file or module"
---

Analyze the specified file or module for refactoring opportunities.

## Steps

1. Read the file or directory specified in the user's argument (e.g., `/refactor src/services/auth.ts`).
2. If it's a directory, read the key files to understand the module structure.
3. Launch the `refactorer` agent with the source files to get structured findings.
4. Present the findings to the user, ordered by impact (high first), with concrete before/after examples.
