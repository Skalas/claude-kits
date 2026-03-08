---
name: api-design
description: "Design or review a FastAPI endpoint for AI connector services"
---

Design or review an API endpoint for an AI connector service.

## Steps

1. Get the endpoint context from the user's argument or current files (e.g., `/api-design POST /api/v1/completions`).
2. Read the project structure to understand existing patterns (router organization, dependency injection, schema design).
3. Launch the `ai-connector-engineer` agent to design or review:
   - **Route definition** — path, method, status codes, Pydantic request/response schemas
   - **Error handling** — AI API failures, rate limits, timeouts, validation errors
   - **Async patterns** — streaming vs batch, background tasks, connection pooling
   - **Security** — authentication, input validation, rate limiting
4. Present the endpoint design with code examples following project conventions.
