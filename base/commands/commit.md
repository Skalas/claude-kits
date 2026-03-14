---
name: commit
description: "Generate a conventional commit message from staged changes. For larger changesets, splits into bisectable commits."
---

Generate a commit for the current staged changes.

## Step 1: Assess the diff

Run `git diff --cached` to see staged changes. If nothing is staged, check `git diff` for unstaged changes. If there are unstaged changes, ask whether to stage everything or let the user select.

## Step 2: Determine commit strategy

Analyze the diff size and scope:

- **Small** (<50 lines, <4 files): Single commit. Go to Step 3.
- **Large** (50+ lines or 4+ files): Consider splitting into bisectable commits. Go to Step 4.

## Step 3: Single commit

Determine:
- **Type**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`, `build`
- **Scope**: module or area affected (from file paths). Omit if unclear.
- **Description**: what changed, in imperative mood ("add X", not "added X")

Generate the message:
```
type(scope): short description

Body with more detail if the change is non-trivial.
Explain WHY, not WHAT (the diff shows what).
```

Present to the user with options: A) Commit B) Edit the message C) Cancel

## Step 4: Bisectable commits (larger changesets)

Split staged changes into logical groups. Each commit must be independently valid — no broken imports, no references to missing code.

Ordering:
1. **Infrastructure** — migrations, config, routes, dependencies
2. **Core logic** — models, services, domain code (with their tests)
3. **Integration** — controllers, views, API endpoints (with their tests)
4. **Housekeeping** — documentation, changelog, version bumps

Rules:
- A source file and its test file belong in the same commit
- Each commit gets its own conventional commit message
- Present the full split plan to the user before executing

## Rules

- **Imperative mood.** "Add feature" not "Added feature" or "Adds feature."
- **50 char limit** on the first line. Wrap body at 72 chars.
- **No generic messages.** "fix: resolve race condition in payment processing" not "fix: fix bug."
- **Scope is optional.** Only include when it adds clarity.
