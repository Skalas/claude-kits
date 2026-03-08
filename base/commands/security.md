---
name: security
description: "Run a security audit on a file, module, or the whole project"
---

Run a security audit on the specified target.

## Steps

1. Determine the target:
   - If the user specified a file or directory (e.g., `/security src/auth`), read those files.
   - If no argument was given, check for staged changes with `git diff --cached`. If there are staged changes, audit those. Otherwise, identify key entry points (routes, controllers, middleware) and audit those.
2. Launch the `security-auditor` agent with the relevant source files.
3. Present the findings to the user, ordered by severity (critical first), with remediation steps.
