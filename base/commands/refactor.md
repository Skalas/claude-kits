---
name: refactor
description: "Identify refactoring opportunities in a file or module"
---

Analyze the specified file or module for refactoring opportunities.

## Step 1: Read and understand

1. Read the file or directory specified in the user's argument (e.g., `/refactor src/services/auth.ts`).
2. If it's a directory, read key files to understand the module structure and existing patterns.
3. Check for test coverage: `grep -r "describe\|test\|it(" test/ spec/ __tests__/ -l 2>/dev/null` — the refactorer agent needs to know what's safe to change.

## Step 2: Analyze

Launch the `refactorer` agent with:
- The source files to analyze
- Any existing test files for those sources
- Note on test coverage level (high/medium/low/none)

## Step 3: Present findings

Present findings ordered by impact (high first). For each finding, include the before/after code example.

If the user wants to proceed with any refactoring, apply the changes and run the test suite to verify nothing broke.

## Rules

- **Read-only by default.** Only modify code if the user explicitly says to proceed.
- **Prioritize actively-changed code.** If git shows a file hasn't been modified in 6 months and it works, leave it alone.
- **Test coverage matters.** Flag high-risk refactorings in untested code — recommend adding tests first.
