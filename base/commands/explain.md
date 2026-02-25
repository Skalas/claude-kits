---
name: explain
description: "Explain the architecture and purpose of a file or module"
---

Explain the architecture, purpose, and key design decisions of the specified file or module.

## Steps

1. Read the file or directory specified in the user's argument (e.g., `/explain src/modules/auth`).
2. If it's a directory, read key files to understand the structure (entry points, module definitions, main exports).
3. Provide a concise explanation covering:
   - **Purpose**: What this module/file does and why it exists
   - **Architecture**: How it fits into the broader system (which layer, what it depends on, what depends on it)
   - **Key abstractions**: Important classes, interfaces, or functions and their responsibilities
   - **Data flow**: How data moves through this module
   - **Design decisions**: Any notable patterns, trade-offs, or non-obvious choices
4. Keep the explanation concise — aim for clarity, not exhaustiveness.
