---
name: simplify
description: "Review changed code for reuse, quality, and efficiency, then fix any issues found."
---

Post-implementation review. Look at what was just built and strip unnecessary complexity.

## Step 1: Get the diff

```bash
git diff main...HEAD
```

If no diff against main, use `git diff HEAD~3` to review recent commits.

## Step 2: Analyze for unnecessary complexity

Launch the `refactorer` agent on the changed files, specifically asking it to focus on:

1. **Over-abstraction** — classes/interfaces/wrappers with only one implementation that aren't at an architecture boundary
2. **Premature generalization** — code parameterized for cases that don't exist yet
3. **Unnecessary indirection** — functions that just call another function with the same arguments
4. **Dead code** — unused imports, unreachable branches, commented-out code introduced in this diff
5. **Over-engineering** — same result achievable with fewer files, layers, or data structures
6. **Duplicate logic** — repeated logic that could be extracted (but not if serving different purposes)

## Step 3: Check for native replacements

Review the diff for:

1. **Native APIs** — dependencies used where a built-in language feature works (`fetch` vs axios, `Intl` vs moment, native array methods vs lodash)
2. **Framework features** — manually implemented behavior the framework provides out of the box
3. **Verbose patterns** — multi-line blocks replaceable with a clearer one-liner (without sacrificing readability)

## Step 4: Present findings and fix

For each finding:
```
[SIMPLIFY] file:line — What's unnecessary and why
  Before: [current code, abbreviated]
  After: [simplified code]
```

If any findings exist, apply the fixes directly. These are safe simplifications, not behavioral changes — the code should do exactly the same thing with less complexity.

After applying fixes, run the project's test suite to verify nothing broke.

## Rules

- **Only simplify, never change behavior.** The output must be functionally identical to the input.
- **Three similar lines is fine.** Don't extract an abstraction for code that appears twice. Wait for the third occurrence.
- **Readability beats brevity.** A clear 5-line block is better than a clever 1-liner.
- **Don't touch stable code.** Only review files changed in the current diff.
- **Run tests after changes.** If tests fail, revert the simplification — the "simpler" version was wrong.
