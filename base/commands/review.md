---
name: review
description: "Pre-landing review. Two-pass analysis of diff against main for structural issues that tests don't catch."
---

Run a pre-landing review on the current branch's diff against main.

## Step 1: Determine what to review

1. Run `git branch --show-current`. If on `main`, output: "Nothing to review — you're on main." and stop.
2. Run `git fetch origin main --quiet && git diff origin/main --stat` to check for changes. If no diff, stop.
3. If the user specified a file or module, scope the review to those paths. Otherwise, review the full diff.

## Step 2: Get the diff

```bash
git fetch origin main --quiet
git diff origin/main
```

This captures both committed and uncommitted changes against the latest main.

## Step 3: Two-pass review

Launch the `code-reviewer` agent with the diff. Instruct it to run two passes:

**Pass 1 — CRITICAL (must fix before merge):**
- SQL/command/template injection, XSS
- Hardcoded secrets or credentials
- Race conditions, data loss risks
- Missing auth/authz on new endpoints
- Trust boundary violations (unsanitized external input in sensitive operations)
- Broken invariants (e.g., "exactly one primary" rule that can break under concurrency)

**Pass 2 — INFORMATIONAL (should fix, not a blocker):**
- N+1 queries, missing indexes
- Dead code, unused imports
- DRY violations, magic numbers/strings
- Missing error handling, swallowed exceptions
- Test gaps for new code paths
- Naming/clarity issues

Also launch the `security-auditor` agent in parallel on the same diff for a security-focused pass.

## Step 4: Present findings

Merge findings from both agents. Deduplicate overlapping issues (prefer the more specific finding).

Output header: `Pre-Landing Review: N issues (X critical, Y informational)`

- **All findings are shown** — both critical and informational. Never hide issues.
- Group by file, order by severity (critical first).
- Each finding: one-line problem, one-line fix. No preamble.

## Step 5: Handle critical issues

If CRITICAL issues found, for EACH one use AskUserQuestion:
- State the problem (file:line + description)
- Recommend the fix
- Options: A) Fix it now B) Acknowledge and ship anyway C) False positive — skip

If user chose A on any issue: apply the fix. Do NOT commit — let the user decide when to commit.

If only informational issues found or no issues: done. No further action needed.

## Rules

- **Read the FULL diff before commenting.** Do not flag issues already addressed elsewhere in the diff.
- **Read-only by default.** Only modify files if the user explicitly chooses "Fix it now."
- **Be terse.** One line problem, one line fix. No preamble.
- **Only flag real problems.** If it's fine, skip it.
- **Never invent issues.** If the code is clean, say so.
