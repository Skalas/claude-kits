---
name: todo
description: "Scan codebase for TODO, FIXME, HACK, and XXX comments and prioritize them"
---

Scan the codebase for action items left in code comments.

## Step 1: Search

Search for markers, excluding vendor/generated directories:

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|WARN" \
  --include="*.ts" --include="*.js" --include="*.py" --include="*.rb" \
  --include="*.go" --include="*.rs" --include="*.java" --include="*.vue" \
  --include="*.tsx" --include="*.jsx" \
  --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=dist \
  --exclude-dir=.git --exclude-dir=__pycache__ \
  . 2>/dev/null
```

## Step 2: Categorize and enrich

For each finding, extract:
- File path and line number
- The full comment text
- The marker type

Categorize by priority:
- **Critical** (`FIXME`, `HACK`) — things that are broken or working around a problem
- **Action needed** (`TODO`) — planned work that hasn't been done
- **Informational** (`XXX`, `WARN`) — notes and warnings

Check git blame for age: `git log -1 --format="%ar" -- <file>` for each file. Old TODOs (6+ months) are flagged as stale.

## Step 3: Present

```
TODO Scan: N items (X critical, Y action needed, Z informational)

## Critical (FIXME/HACK)
- file:line — comment text [age: 3 months ago]

## Action Needed (TODO)
- file:line — comment text [age: 2 weeks ago]
- file:line — comment text [STALE: 8 months ago]

## Informational (XXX/WARN)
- file:line — comment text
```

## Rules

- **Stale TODOs are a smell.** Flag any TODO older than 6 months — it's either not important enough to do or important enough to track properly.
- **Group by file** within each priority level for easier navigation.
- **Skip vendor/generated code.** Only scan source files.
