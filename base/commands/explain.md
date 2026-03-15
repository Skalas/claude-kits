---
name: explain
description: "Explain the architecture and purpose of a file or module"
---

Explain the architecture, purpose, and key design decisions of the specified file or module.

## Step 1: Read and understand

1. Read the file or directory specified in the user's argument (e.g., `/explain src/modules/auth`).
2. If it's a directory, read key files: entry points, module definitions, main exports. Use the `Explore` agent for large modules.
3. Trace dependencies — what does this module import? What imports it?

## Step 2: Explain

Present a concise explanation covering:

- **Purpose** — What this module/file does and why it exists, in 1-2 sentences.
- **Architecture** — Which layer (domain/application/infrastructure/presentation), what depends on it, what it depends on. Include an ASCII dependency diagram if >3 dependencies.
- **Key abstractions** — Important classes, interfaces, or functions. For each: name, responsibility, and why it exists.
- **Data flow** — How data enters, transforms, and exits this module.
- **Design decisions** — Notable patterns, trade-offs, or non-obvious choices. If something looks weird but is intentional, explain why.

## Rules

- **Concise over exhaustive.** Aim for 1-2 pages, not 10. The user can ask follow-up questions.
- **Explain the why, not just the what.** "This uses a repository pattern because the domain layer can't depend on Prisma directly" — not just "This is a repository."
- **Flag concerns.** If something looks wrong (layer violation, missing abstraction, unclear naming), mention it briefly. This is `/explain`, not `/refactor`, so just note it.
- **No code changes.** This command is read-only.
