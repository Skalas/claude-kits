---
name: review
description: "Review staged or recent code changes for quality issues"
---

Review the current code changes for quality issues.

## Steps

1. Check for staged changes with `git diff --cached`. If there are none, check for unstaged changes with `git diff`. If there are none, review the most recent commit with `git diff HEAD~1`.
2. Launch the `code-reviewer` agent with the diff to get structured findings.
3. Present the findings to the user, grouped by file and ordered by severity (blockers first).
