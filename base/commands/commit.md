---
name: commit
description: "Generate a conventional commit message from staged changes"
---

Generate a commit message for the current staged changes.

## Steps

1. Run `git diff --cached` to see staged changes. If nothing is staged, tell the user to stage changes first with `git add`.
2. Analyze the diff and determine:
   - The type of change: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`, `build`, `style`
   - The scope (module/area affected), if obvious from the file paths
   - A concise description of what changed and why
3. Generate a conventional commit message in this format:
   ```
   type(scope): short description

   Optional body with more detail if the change is non-trivial.
   ```
4. Present the message and ask the user if they want to commit with it, modify it, or cancel.
