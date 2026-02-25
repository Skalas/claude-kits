---
name: standup
description: "Generate a standup summary from recent git activity"
---

Generate a standup-style summary of recent work.

## Steps

1. Run `git log --oneline --since="yesterday" --author="$(git config user.name)"` to find recent commits. If no commits since yesterday, widen to the last 3 days.
2. Group commits by theme or feature area.
3. Present a brief standup summary in this format:

**Done**
- Bullet points of completed work, grouped by feature/area

**In Progress**
- Any branches with uncommitted changes (`git status`, `git branch`)

Keep it concise — standup summaries should be scannable in 30 seconds.
