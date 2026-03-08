---
name: profile
description: "Analyze a file or endpoint for performance issues using USE/RED methods"
---

Analyze the specified code for performance issues.

## Steps

1. Read the file or module specified in the user's argument (e.g., `/profile src/services/search.ts`).
2. If it's an endpoint, trace the full request path from route handler through services to database queries.
3. Launch the `performance-engineer` agent to analyze:
   - **Sync/async issues** — blocking calls in async context, sequential awaits that could be parallel
   - **Database** — N+1 queries, missing indexes, unbounded queries, connection pool sizing
   - **Concurrency** — thread/worker configuration, connection pool sizing, backpressure handling
   - **Memory** — large object allocations, potential leaks, missing cleanup
   - **Caching** — opportunities for caching, existing cache invalidation issues
4. Present findings with specific measurements, profiling commands the user can run, and concrete fixes.
