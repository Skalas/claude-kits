---
name: todo
description: "Scan codebase for TODO, FIXME, HACK, and XXX comments and prioritize them"
---

Scan the codebase for action items left in code comments.

## Steps

1. Search the codebase for comments containing `TODO`, `FIXME`, `HACK`, `XXX`, and `WARN` markers using grep.
2. For each finding, extract:
   - The file path and line number
   - The full comment text
   - The surrounding code context (2-3 lines)
3. Categorize findings by priority:
   - **Critical**: `FIXME` and `HACK` — things that are broken or working around a problem
   - **Action needed**: `TODO` — planned work that hasn't been done
   - **Informational**: `XXX` and `WARN` — notes and warnings
4. Present findings grouped by priority, then by file. Include a total count summary at the top.
