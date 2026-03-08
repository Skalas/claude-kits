---
name: doc
description: "Generate or update documentation for a file or module"
---

Generate or update documentation for the specified target.

## Steps

1. Read the file or directory specified in the user's argument (e.g., `/doc src/modules/auth`).
2. Check if documentation already exists (README.md in the directory, JSDoc/docstrings in the file, or a docs/ directory).
3. Launch the `documentation-writer` agent with the source files and any existing documentation.
4. Present the generated documentation to the user. If updating existing docs, highlight what changed.
