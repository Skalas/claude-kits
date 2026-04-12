---
name: ship
description: "Automated shipping workflow: merge main, run tests, review diff, commit, push, create PR. For a ready branch, not for deciding what to build."
---

You are running the `/ship` workflow. This is a **fully automated, non-interactive** pipeline. Do NOT ask for confirmation at any step unless explicitly noted below. The user said `/ship` — execute straight through and output the PR URL at the end.

## When to stop

Only stop for:
- On `main` branch (abort immediately)
- Merge conflicts that can't be auto-resolved
- Test failures
- Pre-landing review finds CRITICAL issues (ask per issue: fix / acknowledge / skip)

Never stop for:
- Uncommitted changes (always include them)
- Commit message wording (auto-generate)
- CHANGELOG content (auto-generate if file exists)

---

## Step 1: Pre-flight

1. Check the current branch. If on `main`: **abort** with "You're on main. Ship from a feature branch."
2. Run `git status`. Note uncommitted changes — they're included automatically.
3. Run `git diff main...HEAD --stat` and `git log main..HEAD --oneline` to understand what's being shipped.

---

## Step 2: Merge origin/main

Fetch and merge to ensure tests run against the merged state:

```bash
git fetch origin main && git merge origin/main --no-edit
```

- **Merge conflicts:** Try to auto-resolve simple ones (lock files, version files). If complex, **STOP** and show them.
- **Already up to date:** Continue silently.

---

## Step 3: Run tests

Detect the project's test runner and execute:

- `package.json` with test script → `npm test` or `bun test`
- `pytest.ini` / `pyproject.toml` / `setup.cfg` → `pytest`
- `Makefile` with test target → `make test`
- `Cargo.toml` → `cargo test`
- If unclear, check `CLAUDE.md` or `README.md` for test instructions

Run tests and capture output.

- **If tests fail:** Show failures and **STOP**. Do not proceed.
- **If tests pass:** Note counts briefly, continue.
- **If no test runner found:** Warn the user and continue (don't block shipping).

---

## Step 4: Pre-landing review

Run a two-pass review on the full diff against main. This is the same rigor as `/review` but inline.

1. Get the diff: `git diff origin/main`
2. **Pass 1 (CRITICAL):** Look for:
   - SQL injection / command injection / XSS
   - Hardcoded secrets or credentials
   - Race conditions in concurrent code
   - Data loss risks (destructive operations without confirmation)
   - Missing authentication/authorization on new endpoints
   - Trust boundary violations (unsanitized external input used in sensitive operations)

3. **Pass 2 (INFORMATIONAL):** Look for:
   - N+1 queries, missing indexes
   - Dead code, unused imports
   - DRY violations, magic numbers
   - Missing error handling
   - Test gaps for new code paths

4. Output: `Pre-Landing Review: N issues (X critical, Y informational)`

5. **If CRITICAL issues found:** For EACH critical issue, use AskUserQuestion with:
   - The problem (file:line + description)
   - Recommended fix
   - Options: A) Fix now B) Acknowledge and ship anyway C) False positive — skip

   If user chose A on any issue: apply fixes, commit them (`git add <files> && git commit -m "fix: pre-landing review fixes"`), then continue.

6. **If only informational:** Output them for visibility, continue.
7. **If none:** Output "Pre-Landing Review: No issues found." and continue.

---

## Step 5: Commit

### Small changes (<50 lines, <4 files)
Single commit is fine:
```bash
git add -A
git commit -m "<type>(<scope>): <description>"
```

### Larger changes
Split into logical, bisectable commits. Each commit = one coherent change. Order by dependency:
1. Infrastructure (migrations, config, routes)
2. Models & services (with their tests)
3. Controllers & views (with their tests)
4. Final housekeeping (changelog, version bumps)

Rules:
- Each commit must be independently valid — no broken imports
- A source file and its test go in the same commit
- Use conventional commit prefixes: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`

---

## Step 6: Push

```bash
git push -u origin $(git branch --show-current)
```

Never force push. If push is rejected, **STOP** and tell the user.

---

## Step 7: Create PR

Create a pull request using `gh` (GitHub CLI):

```bash
gh pr create --title "<type>(<scope>): <summary>" --body "$(cat <<'EOF'
## Summary
<concise bullet points of what changed>

## Pre-Landing Review
<findings from Step 4, or "No issues found.">

## Tests
- [x] All tests pass (N tests, 0 failures)

---
Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

If `gh` is not available, output the PR title and body for manual creation.

**Output the PR URL** — this is the last thing the user sees.

---

## Rules

- **Never skip tests.** If tests fail, stop.
- **Never force push.** Regular `git push` only.
- **Never ask for confirmation** except for CRITICAL review findings.
- **Include uncommitted changes.** The user said `/ship` — everything goes.
- **The goal:** user says `/ship`, next thing they see is the PR URL.
