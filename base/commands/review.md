---
name: review
description: "Pre-landing review. Three-reviewer analysis (correctness, security, elegance) of diff against main for structural issues that tests don't catch."
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

## Step 3: Three-reviewer parallel review

Launch three agents **in parallel** on the same diff. Each owns a tier:

**`code-reviewer` + `security-auditor` → CRITICAL (must fix before merge):**
- SQL/command/template injection, XSS
- Hardcoded secrets or credentials
- Race conditions, data loss risks
- Missing auth/authz on new endpoints
- Trust boundary violations (unsanitized external input in sensitive operations)
- Broken invariants (e.g., "exactly one primary" rule that can break under concurrency)
- **Runtime correctness**: does the change survive its deployment model? (scale-to-zero / SIGTERM killing in-flight work, work that exceeds the platform timeout, missing retry/dead-letter). The diff can be clean and still be wrong for how it actually runs.

`code-reviewer` also reports INFORMATIONAL items (N+1 queries, dead code, magic values, missing error handling, test gaps).

**`refactorer` → DESIGN (elegance & simplicity):**
Run it **report-only** and **scoped to the diff**. Ask it to focus on:
- Over-abstraction (interface/wrapper with one impl, not at an architecture boundary)
- Premature generalization — parameterized for cases that don't exist yet
- Unnecessary indirection, layer violations (logic in the wrong Clean Architecture layer)
- Native/framework replacements (built-in feature reimplemented by hand)
- KISS/DRY violations, and naming that doesn't reveal intent

Its standard guardrails apply: three similar lines is fine, don't touch what works, only flag a finding when there's a concrete simpler alternative. DESIGN is not style nitpicking — every finding needs a before/after.

## Step 4: Present findings — ALWAYS print the full review

Merge findings from all three agents. Deduplicate overlapping issues (prefer the more specific finding).

Output header: `Pre-Landing Review: N issues (X critical, Y design, Z informational)`

- **Always print the complete review to screen** — every tier, every finding — before taking any action. Never hide issues, and never skip the printout even when there's nothing to apply.
- Group by file, order by tier (CRITICAL → DESIGN → INFORMATIONAL).
- Each finding: one-line problem, one-line fix. DESIGN findings include a brief before/after. No preamble.

## Step 5: Handle CRITICAL issues (blocking gate)

If CRITICAL issues found, for EACH one use AskUserQuestion:
- State the problem (file:line + description)
- Recommend the fix
- Options: A) Fix it now B) Acknowledge and ship anyway C) False positive — skip

If user chose A: apply the fix. If user chose B: record the accepted risk and drop a `DEBT:` comment at the site naming the deferred fix (see Step 7) — don't let it evaporate into the summary. Do NOT commit — let the user decide when to commit.

## Step 6: Handle DESIGN findings (suggest to apply)

DESIGN findings are behavior-preserving simplifications. After the full review is printed, **offer to apply them** via AskUserQuestion:
- Options: A) Apply all B) Let me pick C) None — leave as-is

If A or B: apply the chosen simplifications directly, then run the project's test suite. If any test fails, revert that simplification — the "simpler" version was wrong. Do NOT commit.

## Step 7: Leave a debt trail for what wasn't applied

For each DESIGN finding the user declined (and each "ship anyway" from Step 5) that has a real future upgrade, drop a one-line debt comment at the site so `/todo` can harvest it later:

```
# DEBT(simplify): <current ceiling> → <trigger to upgrade>
```

Example: `# DEBT(simplify): inline if/elif dispatch → extract to a handler map when a 3rd branch appears`.

Only leave debt for findings with a concrete upgrade trigger. A pure nitpick that the user rejected gets no comment — silence beats noise.

If no DESIGN or CRITICAL issues: done. The printed review stands on its own.

## Relationship to /simplify and /todo

- `/review` **finds and suggests** across all three tiers; it's the full pre-landing round.
- `/simplify` is the standalone, deliberate **apply-only** elegance pass — reach for it when you want cleanup without a full review. Both drive the `refactorer` agent on the same DESIGN smells; don't restate the taxonomy, defer to the agent.
- `/todo` is where declined work resurfaces — it harvests the `DEBT:` comments this command leaves.

## Rules

- **Read the FULL diff before commenting.** Do not flag issues already addressed elsewhere in the diff.
- **Read-only by default.** Only modify files if the user explicitly chooses "Fix it now."
- **Be terse.** One line problem, one line fix. No preamble.
- **Only flag real problems.** If it's fine, skip it.
- **Never invent issues.** If the code is clean, say so.
