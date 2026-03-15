---
name: doc
description: "Generate or update documentation for a file or module"
---

Generate or update documentation for the specified target.

## Step 1: Understand the target

1. Read the file or directory specified in the user's argument (e.g., `/doc src/modules/auth`).
2. Check for existing documentation:
   - README.md in the directory
   - JSDoc/docstrings in source files
   - docs/ directory or wiki links
   - ADRs (Architecture Decision Records)
3. If updating existing docs, read them fully — preserve structure and only modify what's changed or stale.

## Step 2: Generate

Launch the `documentation-writer` agent with:
- The source files to document
- Any existing documentation (to update rather than replace)
- The documentation type (auto-detect: README for directories, API docs for routes/controllers, module docs for libraries)

## Step 3: Present

- If creating new docs: present the complete file.
- If updating existing docs: show a diff of what changed and why.
- Ask the user to confirm before writing the file.

## Rules

- **Don't generate empty sections.** If there's nothing to say about deployment, omit it.
- **Update, don't replace.** If docs exist, preserve the existing structure and voice.
- **Verify examples work.** Code examples in documentation should be copy-pasteable and correct.
