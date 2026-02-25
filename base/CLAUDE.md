# Team Engineering Standards

These standards apply to all work regardless of domain or technology. Profile-specific conventions extend — never contradict — these principles.

## Clean Architecture

Organize code in layers with dependencies pointing inward:

1. **Domain** (innermost) — Core business logic, entities, value objects, repository interfaces, custom exceptions. No framework imports. Pure language constructs.
2. **Application** — Use cases and services that orchestrate domain logic. Depends only on domain interfaces. Contains DTOs/schemas and port definitions.
3. **Infrastructure** — Concrete implementations: database adapters, external API clients, messaging, file storage. Implements the ports defined in the application layer.
4. **Presentation** (outermost) — Controllers, routers, CLI handlers, middleware. Thin — validates input, calls application services, returns responses.

The domain and application layers must never import from infrastructure or presentation. Enforce this through module boundaries and interfaces.

## DRY (Don't Repeat Yourself)

- Extract shared logic into well-named utility functions, base classes, or shared services
- Use generics and protocols/interfaces for repeated patterns
- Centralize validation rules, error messages, configuration constants, and retry policies
- Share data transfer schemas through inheritance or composition when appropriate
- Never sacrifice clarity for DRY — if two things look similar but serve different purposes, keep them separate

## KISS (Keep It Simple, Stupid)

- Choose the simplest solution that satisfies the requirements
- Avoid unnecessary abstractions — don't create an interface for a class that will only ever have one implementation (unless it's at an architecture boundary)
- Prefer composition over deep inheritance hierarchies
- Use framework built-in features before reaching for external libraries
- If a pattern feels overly complex, step back and simplify
- Flat is better than nested: avoid deeply nested conditionals and callbacks

## Clean Code

- **Naming**: Names reveal intent. A function name tells you what it does without reading the body. Use domain language consistently.
- **Functions**: Small, focused, single-responsibility. Ideally under 20 lines. One level of abstraction per function.
- **Comments**: Code should be self-documenting. Only comment *why*, never *what*. If you need a comment to explain what the code does, refactor the code instead.
- **Error handling**: Use domain-specific exceptions and structured error responses. Never swallow errors. Never use generic catch-all error messages.
- **No magic**: No magic numbers, no magic strings. Use enums, constants, and configuration.

## Working Approach

1. **Understand first** — Read existing code, understand the module structure, and identify established patterns before writing anything
2. **Design before building** — Outline architecture, data model, and API contracts before implementation
3. **Build in layers** — Domain first, then application, then infrastructure, then presentation
4. **Validate your work** — Verify the code compiles, imports resolve, schemas are valid, and tests pass
5. **Simplify** — After implementation, review for unnecessary complexity. Remove anything that doesn't serve the requirements

## Communication Style

- Be concise — explain decisions briefly, not exhaustively
- When trade-offs exist, state them and recommend the simpler option unless complexity is justified
- Flag potential issues proactively — don't wait to be asked
- If requirements are ambiguous, state your assumptions and proceed
