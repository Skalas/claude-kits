---
name: deploy-check
description: "Pre-flight validation for GCP Cloud Run deployments. Checks secrets, env vars, project ID, and common misconfiguration patterns before deploying — works for both manual and Cloud Build workflows."
---

Run a pre-flight validation before deploying to GCP Cloud Run. This command does NOT deploy — it audits the current state and flags issues that commonly cause deployment failures.

## Steps

### 1. Determine deployment context

Ask the user (if not already clear from context):
- **Which service?** (service name in Cloud Run)
- **Which environment?** (dev, stage, prod)
- **Which GCP project?** (project ID)

If the project has a `cloudbuild.yaml`, `Makefile`, or deploy scripts, read them to infer defaults. Don't ask what's already in the config files.

### 2. Verify GCP project

```bash
gcloud config get-value project
```

Compare the active project against the expected project for the target environment. Flag a **BLOCKER** if they don't match.

### 3. Audit live service configuration

Query the deployed service's current state:

```bash
gcloud run services describe SERVICE_NAME \
  --region=REGION \
  --format='yaml(spec.template.spec.containers[0])' \
  --project=PROJECT_ID
```

Extract and check:
- **Environment variables**: List all env vars currently set on the live service
- **Secrets**: List all secret volume mounts and env var references
- **Resources**: CPU, memory, min/max instances
- **Image**: Current deployed image tag/digest

### 4. Run validation checks

Check each of the following. Categorize findings as **BLOCKER** (will cause deployment failure or runtime error), **WARNING** (likely problem), or **INFO** (worth knowing).

#### Secrets validation
- **Quoted values**: Check if any secret values are wrapped in quotes (e.g., `"-----BEGIN PRIVATE KEY-----"` instead of the raw value). Quoted PEM keys are the #1 silent failure mode.
  ```bash
  gcloud secrets versions access latest --secret=SECRET_NAME --project=PROJECT_ID | head -c 5
  ```
  If a PEM secret starts with `"` instead of `-`, flag as **BLOCKER**.
- **URL-encoded passwords**: Check if database passwords contain URL-encoded characters (`%40`, `%23`, etc.) that should be raw. Flag as **WARNING**.
- **Secret existence**: Verify each referenced secret actually exists in the target project.

#### Environment variables
- **Overwrite risk**: If the project uses `--set-env-vars` anywhere (Makefile, cloudbuild.yaml, deploy scripts), flag as **WARNING** — this replaces ALL env vars. Recommend `--update-env-vars` instead.
- **Environment mismatch**: Check that env-specific values (database URLs, API endpoints, project references) point to the correct environment. A `dev` database URL in a `prod` service is a **BLOCKER**.
- **Missing vars**: Compare env vars expected by the application (from `.env.example`, config files, or docker-compose) against what's set on the live service.

#### Image and build
- **Image tag**: Flag `latest` tag as **WARNING**. Prefer git SHA or semver tags.
- **Image exists**: Verify the image exists in Artifact Registry if a specific tag is being deployed.

#### Networking and connectivity
- **VPC connector**: If the service needs private networking (Cloud SQL, Memorystore), verify a VPC connector is configured.
- **Cloud SQL connection**: If using Cloud SQL, check that the connection name is set and the service account has `cloudsql.client` role.

### 5. Report findings

Present a structured report:

```
## Deploy Check: SERVICE_NAME → ENVIRONMENT

### Active GCP Project: PROJECT_ID ✓/✗

### Blockers (must fix before deploying)
- [list or "None found"]

### Warnings (likely problems)
- [list or "None found"]

### Info
- Current image: ...
- Min instances: ...
- Env vars count: ...
- Secrets count: ...
```

If there are blockers, do NOT proceed. Explain each blocker and suggest the fix.
If clean, say so and remind the user to proceed with their usual deployment method (manual or Cloud Build) — this command intentionally does not deploy.

## Rules

- **Read-only.** This command never modifies infrastructure. It only reads and reports.
- **No assumptions about deployment method.** The user may deploy via `gcloud run deploy`, `gcloud builds submit`, a `Makefile`, or a CI pipeline. This command validates the *state*, not the *method*.
- **Check the live service, not just local files.** Local config can be correct while the live service has drifted. Always query the actual deployed state.
- **Be specific about fixes.** Don't just say "secret is misconfigured" — show the exact value prefix and what it should be.
