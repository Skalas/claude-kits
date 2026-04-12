---
name: standup
description: "Generate a standup summary from recent git activity with metrics"
---

Generate a standup summary of recent work with key metrics.

## Step 1: Gather data

Run all of these in parallel (they're independent):

```bash
# Who am I?
git config user.name

# Recent commits (widen to 3 days if yesterday is empty)
git log --oneline --since="yesterday" --author="$(git config user.name)"

# Commit stats (LOC, files)
git log --since="yesterday" --author="$(git config user.name)" --format="%H|%s" --shortstat

# Current branch and status
git branch --show-current
git status --short

# All local branches with recent activity
git branch --sort=-committerdate --format="%(refname:short) %(committerdate:relative)" | head -10

# Open PRs (if gh is available)
gh pr list --author="@me" --state=open --limit=5 2>/dev/null || true
```

If no commits since yesterday, widen to `--since="3 days ago"` and note it.

## Step 2: Compute metrics

Quick stats for the period:
- Commits count
- Files changed
- Lines added/removed
- Commit type breakdown (feat/fix/refactor/test/chore — from prefixes)

## Step 3: Present summary

```
Standup: [date] | [N] commits, +[X]/-[Y] lines, [Z] files

## Done
- [grouped by feature/area, one bullet per logical unit of work]
- [reference commit type: feat, fix, refactor, etc.]

## In Progress
- [current branch]: [uncommitted changes summary, or "clean"]
- [other active branches with recent commits]

## Open PRs
- #123: title (status: review/draft/approved)
```

## Rules

- **30 seconds to read.** Standup summaries are scannable, not exhaustive.
- **Group by theme, not by commit.** "Built the payment webhook handler" not three separate commit descriptions.
- **Metrics are one line.** Don't elaborate unless something is unusual.
- **No open PRs section** if `gh` is unavailable or returns nothing.
