---
name: create-component
description: "Scaffold a new Vue 3 component with TypeScript and Composition API"
---

Scaffold a new Vue 3 component following project conventions.

## Steps

1. Get the component name and type from the user's argument (e.g., `/create-component UserCard` or `/create-component ui/BaseDialog`).
2. Determine the component type from the path:
   - `ui/` prefix → generic reusable component in `src/components/ui/`
   - `features/` prefix → domain component in `src/components/features/`
   - No prefix → ask the user which type
3. Read the project to match established patterns (naming, styling approach, prop conventions).
4. Launch the `vue-engineer` agent to generate:
   - The `.vue` SFC with `<script setup lang="ts">`, typed props/emits, and scoped styles
   - A corresponding test file with Vitest + Vue Test Utils
5. Present the generated files and ask the user to confirm before writing them.
