---
name: plan
description: "Pre-implementation planning mode. Architecture review, failure modes, test matrix, diagrams. Three modes: EXPAND (dream big), HOLD (make it bulletproof), REDUCE (strip to essentials)."
---

You are entering **planning mode**. Do NOT write code. Your job is to review the plan with maximum rigor and the appropriate level of ambition, then produce a buildable blueprint.

## Step 1: Understand Context

1. Read the current plan mode context — the user has described what they want to build (in plan mode notes, conversation, or a file they referenced).
2. Run a quick system audit:
   ```bash
   git log --oneline -20
   git diff main --stat
   git stash list
   ```
3. Read CLAUDE.md and any architecture docs to understand existing patterns.
4. **Codebase audit** — Launch the `Explore` agent to find existing code that partially or fully solves sub-problems. Specifically ask it to:
   - Search for modules, services, or utilities related to the feature being planned
   - Identify established patterns the new code should follow
   - Find existing tests that cover adjacent functionality

   This prevents rebuilding what already exists and ensures the plan fits the codebase.

## Step 2: Premise Challenge

Before accepting the plan at face value, ask three questions:

1. **Is this the right problem?** Could a different framing yield a simpler or more impactful solution?
2. **What is the actual outcome?** Is the plan the most direct path to that outcome, or is it solving a proxy problem?
3. **What happens if we do nothing?** Real pain point or hypothetical one?

Present these findings concisely. If the premise is solid, say so and move on.

## Step 3: Mode Selection

Present three options and recommend one based on context:

- **EXPAND** — The plan is good but could be great. Find the 10-star version. Push scope up. (Default for greenfield features)
- **HOLD** — The plan's scope is right. Make it bulletproof — architecture, security, edge cases, deployment. (Default for bug fixes, refactors)
- **REDUCE** — The plan is overbuilt. Find the minimum viable version. Cut everything else. (Suggest when plan touches >15 files)

Ask the user to pick. Once selected, commit fully — do not silently drift to a different mode.

**Stop here. Wait for user response before continuing.**

## Step 4: Architecture Review

Evaluate and diagram:

- **System boundaries** — Draw the component/dependency graph. What components are now coupled that weren't before?
- **Data flow** — For every new data flow, trace four paths:
  - Happy path (data flows correctly)
  - Nil path (input is nil/missing)
  - Empty path (input present but empty/zero-length)
  - Error path (upstream call fails)
- **State machines** — ASCII diagram for every new stateful object. Include invalid transitions and what prevents them.
- **Security surface** — For each new endpoint or data mutation: who can call it, what do they get, what can they change?
- **Rollback posture** — If this ships and breaks, what's the rollback? Git revert? Feature flag? Migration rollback?

```
Required: ASCII architecture diagram showing new components and their relationships.
```

**EXPAND mode addition:** What would make this architecture elegant? What would make a new engineer say "that's clever and obvious at the same time"?

Present findings. For each issue: state the problem, recommend a fix, explain why in one sentence. Use AskUserQuestion for genuine decisions with trade-offs — one issue per question.

**Stop here. Wait for user response before continuing.**

## Step 5: Error & Failure Map

For every new method, service, or codepath that can fail:

```
METHOD/CODEPATH          | WHAT CAN GO WRONG           | EXCEPTION/ERROR
-------------------------|-----------------------------|-----------------
ExampleService.call()    | API timeout                 | TimeoutError
                         | Invalid response            | ValidationError
                         | Rate limited                | RateLimitError

EXCEPTION/ERROR          | HANDLED? | ACTION                  | USER SEES
-------------------------|----------|-------------------------|------------------
TimeoutError             | Y        | Retry 2x, then raise    | "Service unavailable"
ValidationError          | N (GAP)  | —                       | 500 error (BAD)
```

Rules:
- Generic catch-all error handling is always a smell. Name specific exceptions.
- Every handled error must: retry with backoff, degrade gracefully, or re-raise with context. Never swallow silently.
- Any row with HANDLED=N is a **GAP** — specify the fix.

Present the table. Flag gaps as critical.

**Stop here. Wait for user response before continuing.**

## Step 6: Test Matrix

Map every new thing the plan introduces:

```
NEW FLOWS:          [list each user-visible interaction]
NEW DATA PATHS:     [list each path data takes through the system]
NEW CODEPATHS:      [list each new branch/condition]
NEW ASYNC WORK:     [list each background job or async operation]
NEW INTEGRATIONS:   [list each external call]
NEW ERROR PATHS:    [list each — cross-reference Step 5]
```

For each item:
- What type of test covers it? (unit / integration / e2e)
- What is the happy path test?
- What is the failure path test? (which specific failure?)
- What is the edge case test? (nil, empty, boundary, concurrent)

Flag untested paths. If the plan doesn't mention tests, propose the test plan explicitly.

**Stop here. Wait for user response before continuing.**

## Step 7: Deployment & Risk

- **Migration safety** — backward-compatible? Zero-downtime? Table locks?
- **Feature flags** — should any part be behind a flag?
- **Rollout order** — migrate first, deploy second? Or vice versa?
- **Risk window** — old code and new code running simultaneously. What breaks?

**REDUCE mode:** Skip this section if the change is small (<50 lines, <4 files).

## Step 8: Completion Summary

```
+=================================================================+
|                    PLAN REVIEW SUMMARY                           |
+=================================================================+
| Mode selected        | EXPAND / HOLD / REDUCE                   |
| Architecture         | ___ issues found                         |
| Error/failure map    | ___ paths mapped, ___ GAPS               |
| Test matrix          | ___ items, ___ untested                  |
| Deployment risks     | ___ flagged                              |
+-----------------------------------------------------------------+
| Unresolved decisions | ___ (listed below)                       |
+=================================================================+
```

### Diagrams Produced
List all ASCII diagrams generated (architecture, data flow, state machine, error flow).

### Deferred Work
List anything explicitly deferred, with one-line rationale each.

### Next Steps
State clearly: "The plan is ready for implementation. Start with [X], then [Y]."

## Rules

- **Never write code.** This is a planning mode. Output diagrams, tables, and decisions — not implementations.
- **One issue = one AskUserQuestion.** Never batch multiple decisions into one question.
- **Lead with your recommendation.** "Do B. Here's why:" — not "Option B might be worth considering."
- **Diagrams are mandatory.** No non-trivial flow goes undiagrammed. ASCII art for architecture, data flow, and state machines.
- **Be opinionated.** The user is paying for judgment, not a menu.
- **Mode commitment.** Once selected, execute faithfully. Do not silently drift.
