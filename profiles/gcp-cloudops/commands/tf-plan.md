---
name: tf-plan
description: "Review a Terraform plan output for risks and best practices"
---

Analyze a Terraform plan for risks, best practices, and potential issues.

## Steps

1. Check if the user provided a plan file or ask them to run `terraform plan -out=tfplan && terraform show -json tfplan`.
2. If no plan output is available, look for recent Terraform files in the project and run a dry analysis on the `.tf` files.
3. Launch the `gcp-cloudops-engineer` agent to review the plan for:
   - **Destructive changes** — resource deletions or recreations that could cause data loss or downtime
   - **Security issues** — public IPs, missing encryption, overly permissive IAM, exposed ports
   - **Cost implications** — new resources, instance sizing, committed use discount eligibility
   - **Best practices** — missing labels/tags, unpinned versions, missing lifecycle rules
4. Present findings categorized by risk level with recommendations.
