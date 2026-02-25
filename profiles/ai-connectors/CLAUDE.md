# AI Connectors Profile

The team engineering standards (Clean Architecture, DRY, KISS, Clean Code) apply. The conventions below extend those standards with domain-specific guidance for AI service integrations.

## Technical Stack

- **Language**: Python (async/await patterns, type hints, best practices)
- **Framework**: FastAPI (routing, dependency injection, middleware, lifecycle events)
- **Environment Management**: direnv for local development and secrets
- **Containerization**: Docker and docker-compose for service orchestration
- **Cloud Platform**: Google Cloud Platform (Cloud Run, Cloud Functions, Secret Manager, Cloud Storage, Pub/Sub)

## AI Connector Design & Implementation

- Design clean, reusable abstractions for AI service integrations (OpenAI, Anthropic, Google AI, etc.)
- Implement async API clients with proper connection pooling and session management
- Handle streaming responses with Server-Sent Events (SSE) or WebSockets when appropriate
- Design request/response schemas using Pydantic models with validation
- Implement proper error handling for API failures, rate limits, and timeouts

## FastAPI Application Development

- Structure applications following best practices (routers, dependencies, middleware)
- Never block the event loop — all I/O operations must be async
- Use dependency injection for services, database connections, and configurations
- Design RESTful endpoints with clear request/response contracts
- Implement health checks, readiness probes, and monitoring endpoints
- Add proper CORS configuration and security headers
- Use background tasks for long-running AI operations when appropriate

## Configuration & Secrets Management

- Use direnv for local environment variable management
- Never hardcode secrets — always use environment variables
- Implement proper configuration loading with validation (pydantic-settings)
- Use GCP Secret Manager for production secrets
- Provide clear `.envrc.example` files with all required variables documented

## Docker & Containerization

- Write optimized, multi-stage Dockerfiles for Python applications
- Use appropriate base images (python:3.11-slim, python:3.11-alpine)
- Implement proper layer caching for faster builds
- Create docker-compose.yml files for local development with all services
- Configure health checks in Docker Compose
- Use volumes for development hot-reloading

## GCP Integration

- Design for Cloud Run deployment (stateless, horizontally scalable)
- Implement proper startup and shutdown handlers
- Use GCP Secret Manager for API keys and credentials
- Integrate with Cloud Storage for file handling if needed
- Consider Cloud Tasks or Pub/Sub for async processing patterns
- Design with cold start optimization in mind

## AI-Specific Best Practices

- Implement exponential backoff retry logic for API calls
- Add circuit breakers for failing AI services
- Track token usage and implement cost monitoring
- Cache AI responses when appropriate (with proper invalidation)
- Implement request timeouts with graceful degradation
- Log AI API calls for debugging and cost analysis
- Handle rate limiting proactively (queue management, throttling)

## Code Quality

- Use type hints throughout (Python 3.10+ syntax)
- Follow PEP 8 and use tools like ruff or black for formatting
- Use async/await consistently — mark all I/O operations as async
- Structure code to be testable: use dependency injection for easy mocking, separate business logic from framework code

## Decision-Making Framework

- **When to use async**: Always for I/O operations (AI API calls, database queries, file operations)
- **When to use background tasks**: For operations that can complete after the response (logging, analytics)
- **When to use caching**: For deterministic AI operations or reference data lookups
- **When to use queues**: For high-volume requests or operations that need guaranteed processing
- **When to use streaming**: For long AI responses where user experience benefits from incremental display

## Quality Assurance

Before considering any implementation complete:
- Verify all async operations are properly awaited
- Confirm environment variables are documented and validated
- Ensure error cases are handled with appropriate status codes
- Check that Docker build works and container runs successfully
- Verify secrets are never in code or version control
- Confirm logging is in place for debugging and monitoring
