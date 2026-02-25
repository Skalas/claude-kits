# Vue Frontend Profile

The team engineering standards (Clean Architecture, DRY, KISS, Clean Code) apply. The conventions below extend those standards with domain-specific guidance for Vue.js frontend development. All code is TypeScript — never use `any`, never skip type definitions.

## Technical Stack

- **Framework**: Vue 3 (Composition API, `<script setup>`, reactivity system)
- **Language**: TypeScript (strict mode, no `any`, proper generics)
- **State**: Pinia (stores, actions, getters)
- **Routing**: Vue Router 4 (guards, lazy loading, typed routes)
- **Build**: Vite
- **Testing**: Vitest + Vue Test Utils
- **Styling**: Project-dependent (scoped CSS, CSS modules, or Tailwind) — follow what's established

## Component-Based Architecture

Components are the unit of design. Every component should be:

- **Single-responsibility**: One component does one thing. If a component has multiple responsibilities, split it
- **Self-contained**: Template, logic, and styles in one SFC. No reaching into other components' internals
- **Composable**: Use props for input, emits for output, slots for content injection. No implicit coupling
- **Layered by role**:
  - **Pages** — route-level components. Orchestrate layout, fetch data, pass to children
  - **Features** — domain-specific components (UserCard, OrderTable). Contain business logic
  - **UI** — generic, reusable components (BaseButton, BaseModal, BaseInput). Zero business logic, fully prop-driven

## SOLID Principles

- **Single Responsibility**: Each component, composable, and store handles one concern
- **Open/Closed**: Components are extensible through props and slots without modifying their internals
- **Liskov Substitution**: Shared component interfaces (e.g., form inputs) must be interchangeable — if `BaseInput` accepts `modelValue` and emits `update:modelValue`, every input variant must too
- **Interface Segregation**: Don't pass large objects as props when a component only needs two fields. Destructure at the parent, pass only what's needed
- **Dependency Inversion**: Components depend on abstractions (composables, injected services), not concrete implementations. Use `provide`/`inject` for cross-cutting concerns

## Vue Conventions

### Components (SFCs)

- Always use `<script setup lang="ts">` — no Options API, no `defineComponent()` boilerplate
- Define props with `defineProps<{}>()` using TypeScript interfaces, not runtime validation
- Define emits with `defineEmits<{}>()` using typed signatures
- Use `v-model` with `defineModel()` for two-way binding
- Use `computed()` for derived state — never compute in the template
- Use `watch` / `watchEffect` sparingly — prefer computed when possible
- Use `ref()` for primitives, `reactive()` for objects — but prefer `ref()` for consistency
- Use `toRefs()` when destructuring reactive objects to preserve reactivity
- Template refs: use `useTemplateRef()` with typed generics

### Composables

- Name them `useXxx` — always a function that returns a reactive interface
- Return explicit types: `{ data: Ref<User[]>, isLoading: Ref<boolean>, error: Ref<Error | null>, refresh: () => Promise<void> }`
- Keep composables focused — one concern per composable
- Composables replace mixins entirely. Never use mixins
- Accept configuration as parameters, return reactive state and methods
- Handle cleanup: use `onUnmounted` or return cleanup functions for intervals, event listeners, subscriptions

### State Management (Pinia)

- One store per domain concept (useUserStore, useCartStore) — not one global store
- Use `defineStore` with the setup syntax for TypeScript consistency
- Keep stores thin — business logic belongs in composables or services, not stores
- Use getters for derived state, actions for mutations and async operations
- Don't put UI state (modals, tabs, tooltips) in Pinia — use local component state or composables

### Routing (Vue Router)

- Lazy-load all page components: `() => import('./pages/Dashboard.vue')`
- Use named routes and typed `RouteLocationRaw` for navigation — never hardcode paths
- Implement navigation guards in a dedicated `router/guards/` directory
- Use `beforeEach` for auth guards, `beforeResolve` for data prefetching
- Use route meta fields for declaring requirements: `meta: { requiresAuth: true, roles: ['admin'] }`

### API Integration

- Centralize API calls in service modules (`services/userService.ts`) — components never call `fetch` directly
- Return typed responses — define interfaces for every API response shape
- Handle errors at the service level with consistent error types
- Use composables (`useUsers`, `useProduct`) to bridge services and components with reactive state, loading, and error handling
- Implement request cancellation with `AbortController` for components that unmount during fetches

### KISS for Vue

- Use `Intl.DateTimeFormat` instead of date-fns/moment for date formatting
- Use CSS `@media` queries instead of a JS resize observer library
- Use `<Teleport>` instead of a portal library
- Use `<Transition>` and CSS instead of an animation library for simple transitions
- Use `v-model` with computed get/set instead of a form library for simple forms
- Evaluate every `npm install` — does this dependency earn its place in the bundle?
- Prefer platform APIs (IntersectionObserver, ResizeObserver, URLSearchParams, structuredClone) over npm packages

## Project Structure

```
src/
├── components/
│   ├── ui/                # generic reusables (BaseButton, BaseInput, BaseModal)
│   └── features/          # domain components (UserCard, OrderRow)
├── composables/           # useXxx composables
├── pages/                 # route-level components
├── router/
│   ├── index.ts
│   └── guards/
├── stores/                # Pinia stores
├── services/              # API service modules
├── types/                 # shared TypeScript interfaces and types
└── utils/                 # pure utility functions (formatters, validators)
```

## Performance

- Lazy-load routes and heavy components with `defineAsyncComponent`
- Use `v-once` for static content that never changes
- Use `v-memo` for expensive list rendering that doesn't change often
- Use `shallowRef` / `shallowReactive` for large objects where deep reactivity isn't needed
- Avoid reactive state in tight loops — use raw values and update reactive refs at the end
- Profile with Vue DevTools performance tab before optimizing — don't guess

## Testing

- **Unit tests**: Test composables and utility functions in isolation
- **Component tests**: Mount with `mount()` / `shallowMount()`, test behavior through user interactions, not implementation details
- **Test what matters**: User-visible behavior, not internal state. Query by role/label, not by CSS class
- Follow Arrange-Act-Assert pattern
- Mock API calls and stores, never test against real backends
