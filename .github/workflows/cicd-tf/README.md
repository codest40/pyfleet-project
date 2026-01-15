# PyFleet Terraform CI/CD Pipeline

This repository contains the **Terraform GitHub Actions CI/CD pipeline** for managing the PyFleet AWS infrastructure.  
It uses **OIDC authentication** to securely access AWS without storing long-lived credentials and supports **dev/prod environments**, **Blue/Green promotion**, **security scans**, **cost monitoring**, and **drift detection**.

---

## Features

- **Environment Support:** 
  - `dev` and `prod` only. 
  - Environment selection is fully managed via workflow inputs.
  
- **Terraform Automation:**  
  - Run `plan`, `apply`, `promote` (Blue/Green switch in prod), or `destroy`.  
  - Fully automated Terraform init, plan, apply, and destroy.

- **Security & Cost Integration:**  
  - **tfsec** for static Terraform security scanning.  
  - **Infracost** for cloud cost estimation and tracking.

- **Drift Detection:**  
  - Daily scheduled workflow detects infrastructure drift.  
  - Creates GitHub issues automatically if drift is detected.

- **Blue/Green Deployment (Prod):**  
  - Active ASG color (`blue` or `green`) toggled automatically during promotion.  
  - No manual edits required in Terraform code.

- **OIDC Authentication:**  
  - Uses GitHub Actions OIDC role to authenticate securely with AWS.  
  - Avoids storing AWS credentials in GitHub secrets.  
  - Environment-specific role ARNs are stored as secrets for security.

---

## Workflows

### 1. `tf.yml` — Terraform CI/CD Pipeline

- Triggered manually via **workflow_dispatch**.  
- Inputs:
  - `tf_env`: Target environment (`dev` / `prod`)
  - `tf_action`: Action to perform (`plan`, `apply`, `promote`, `destroy`)
- Steps:
  1. Checkout repository
  2. Configure AWS credentials (OIDC)
  3. Terraform setup, init, validate, format check
  4. Security scan (tfsec)
  5. Cost scan (Infracost)
  6. Terraform plan/apply/destroy
  7. Blue/Green promotion logic for prod

---

### 2. `tf-drift.yml` — Terraform Drift Detection

- Triggered:
  - Daily via schedule (cron)
  - Manually via **workflow_dispatch**
- Steps:
  1. Checkout repository
  2. Configure AWS credentials (OIDC)
  3. Terraform init
  4. Plan with `-detailed-exitcode` to detect drift
  5. Creates GitHub issue if drift is detected

---

## Running Workflows

### Via GitHub Web UI

1. Go to **Actions → Terraform CI/CD Pipeline (`tf.yml`)**
2. Click **Run workflow**
3. Select:
   - `tf_env`: `dev` or `prod`
   - `tf_action`: `plan`, `apply`, `promote`, `destroy`
4. Click **Run workflow**

### Via GitHub CLI (local)

```bash
# Example: plan in dev
gh workflow run tf.yml -f tf_env=dev -f tf_action=plan

# Example: promote in prod
gh workflow run tf.yml -f tf_env=prod -f tf_action=promote


# Notes

No .tfvars files are required locally; everything is handled via the GitHub workflow.

Blue/Green promotion in production is fully automated; active color is detected and toggled automatically.

Drift detection runs daily for both dev and prod and creates GitHub issues if infrastructure drift is found.

Security and cost scanning are integrated in every workflow run for visibility.


# Summary

This CI/CD setup provides a secure, automated, and fully managed Terraform workflow for PyFleet:

Dev/Prod environment separation

Blue/Green production promotion

Security scanning with tfsec

Cost monitoring with Infracost

Drift detection with automated GitHub issues

OIDC-based AWS authentication for secret-free CI
