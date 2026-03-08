---
name: generate-module
description: "Scaffold a new NestJS feature module with clean architecture layers"
---

Scaffold a new NestJS feature module following the project's clean architecture pattern.

## Steps

1. Get the module name from the user's argument (e.g., `/generate-module orders`).
2. Read the project structure to identify the modules directory (typically `src/modules/`).
3. Look at an existing module to match the project's established patterns (naming, file organization, decorator usage).
4. Launch the `nestjs-engineer` agent to generate the module scaffold with:
   - `domain/entities/` — entity class
   - `domain/repositories/` — repository interface
   - `application/services/` — service with CRUD operations
   - `application/dtos/` — create/update DTOs with class-validator decorators
   - `infrastructure/persistence/` — Prisma repository implementation
   - `presentation/controllers/` — REST controller with Swagger decorators
   - `<module>.module.ts` — NestJS module definition with providers
5. Present the generated files and ask the user to confirm before writing them.
