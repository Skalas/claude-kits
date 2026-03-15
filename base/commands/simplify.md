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

## Step 2: Review for unnecessary complexity

For each changed file, ask:

1. **Over-abstraction** — Is there a class/interface/wrapper that only has one implementation and isn't at an architecture boundary? Remove it.
2. **Premature generalization** — Is code parameterized or configurable for cases that don't exist yet? Simplify to handle only the current case.
3. **Unnecessary indirection** — Is there a function that just calls another function with the same arguments? Inline it.
4. **Dead code** — Are there unused imports, unreachable branches, commented-out code, or unused variables introduced in this diff? Remove them.
5. **Over-engineering** — Could the same result be achieved with fewer files, fewer layers, or simpler data structures?
6. **Duplicate logic** — Is the same logic repeated that could be extracted? (But don't extract if the duplication serves different purposes.)

## Step 3: Review for missing simplifications

1. **Native APIs** — Is there a dependency being used where a built-in language feature would work? (`fetch` vs axios, `Intl` vs moment, native array methods vs lodash)
2. **Framework features** — Is something implemented manually that the framework provides out of the box?
3. **Verbose patterns** — Can any multi-line block be replaced with a clearer one-liner? (But don't sacrifice readability for brevity.)

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
