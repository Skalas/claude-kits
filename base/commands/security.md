---
name: security
description: "Run a security audit on a file, module, or the whole project"
---

Run a security audit on the specified target.

## Step 1: Determine scope

- If the user specified a file or directory (e.g., `/security src/auth`), read those files.
- If no argument was given, determine scope automatically:
  1. Check for staged changes (`git diff --cached`). If present, audit those.
  2. Otherwise, identify key attack surface: routes, controllers, middleware, auth modules, API endpoints. Use the `Explore` agent if the codebase is unfamiliar.

Also gather context:
```bash
# Check for .env files that might be committed
git ls-files | grep -i '\.env' || true
# Check for common security config
ls -la .gitignore Dockerfile docker-compose* 2>/dev/null || true
```

## Step 2: Audit

Launch the `security-auditor` agent with:
- The source files to audit
- Any configuration files (Dockerfiles, CI pipelines, IAM configs)
- The `.gitignore` file (to check if sensitive files are excluded)

## Step 3: Present

Present findings ordered by severity (critical first). For each finding, include the specific remediation with code examples.

Include a summary line: `Security Audit: N findings (X critical, Y high, Z medium)`

If critical findings exist, use AskUserQuestion for each: A) Fix now B) Acknowledge C) False positive.
