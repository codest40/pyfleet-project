#  PyFleet CI/CD Documentation

This document describes the **complete CI/CD architecture, workflows, and design decisions** used in the PyFleet project. The CI/CD system is built with **GitHub Actions** and is tightly integrated with Terraform-based Infrastructure as Code (IaC).

The goal of this CI/CD setup is not only automation, but **reliability, security, auditability, and production-aligned behavior**.

---

## High-Level Goals

The CI/CD system is designed to:

* Automate Terraform workflows safely and predictably
* Use **OIDC-based AWS authentication** (no static credentials)
* Separate **backend lifecycle** from infrastructure lifecycle
* Support multiple environments and deployment strategies
* Enforce security and quality checks before changes are applied
* Remain fully non-interactive and automation-safe

---

## Authentication Model (OIDC)

PyFleet uses **GitHub Actions OIDC** to authenticate to AWS.

### Why OIDC?

* No long-lived AWS access keys
* Credentials are short-lived and scoped
* Native GitHub → AWS trust relationship
* Easier rotation, auditing, and compliance

### Flow

1. GitHub Action requests an OIDC token
2. AWS IAM Role trusts GitHub as an identity provider
3. Temporary credentials are issued via `sts:AssumeRoleWithWebIdentity`
4. Terraform and AWS CLI use these temporary credentials

This eliminates secret sprawl and mirrors production-grade security practices.

---

## Workflow Overview

The `.github/workflows/` directory contains multiple workflows, each with a **single, clear responsibility**:

```text
.github/workflows/
├── tf.yml              # Manual Terraform workflow (plan/apply/destroy/create-backend/destroy-backend)
├── tf-auto.yml         # Automated Terraform execution (Fewer Manula Options)
├── tf-drift.yml        # Drift detection
├── check-state.yml     # Remote state validation
├── test-oidc.yml       # OIDC authentication testing
├── oidc-setup.md       # OIDC setup steps on aws consolde
└── cicd-doc/           # CI/CD documentation (this file)
```

---

## Terraform Backend Lifecycle

### Why Backend Lifecycle Is Separate

Terraform backend resources (S3 + DynamoDB) **must exist before** Terraform can initialize state. Mixing backend creation with normal Terraform runs introduces race conditions and state corruption risks.

### Backend Actions

The CI/CD pipeline supports explicit backend actions:

* `create-backend`
* `destroy-backend`

These actions:

* Create or destroy the S3 backend bucket
* Create or destroy the DynamoDB state lock table
* Verify existence and deletion explicitly

This ensures backend state is **intentional, explicit, and auditable**.

---

## Main Terraform Workflow (`tf.yml`)

This workflow handles **manual and controlled Terraform operations**.

### Supported Actions

* `plan`
* `apply`
* `destroy`
* `promote` (blue/green control)

### Key Characteristics

* Uses `terraform init -reconfigure` to avoid local-state contamination
* Fully non-interactive (`TF_IN_AUTOMATION=true`)
* Environment-aware execution
* Safe defaults (plan before apply)

---

## Automated Terraform Workflow (`tf-auto.yml`)

This workflow is intended for **automated or scheduled execution**, such as:

* Periodic validation
* Create, delete s3 backend intergrated inside plan, apply, destroy unlike tf.yml
* Continuous compliance checks

It runs without manual input and enforces strict consistency.

---

## Drift Detection (`tf-drift.yml`)

Infrastructure drift occurs when deployed resources differ from declared IaC.

### What This Workflow Does

* Runs `terraform plan` against existing state
* Detects out-of-band changes
* Fails or alerts on unexpected drift

This enables **early detection of configuration drift**, a key SRE and platform engineering concern.

---

## State Exists Testing (`check-state.yml`)

This workflow ensures:

* State Testing
* State locking is functional
* Terraform can safely initialize

It acts as a **guardrail** before running destructive or state-dependent operations.


#  State Validation ( scripts/wait-for-lock.sh ) 

This is used to ensure
* Remote backend (S3 + DynamoDB) exists
* State locking is functional
* Detects whether a Terraform state lock is currently held
* Terraform can safely plan, apply when lock is free

### Why it exists

Terraform uses a DynamoDB table for state locking. In CI/CD, multiple workflows (plan, apply, drift detection, promotion) can be triggered close together. If a lock already exists, Terraform will fail immediately.

Instead of failing fast, this project introduces an explicit wait mechanism.

### Prevents:

Concurrent terraform apply

Corrupted state

Failed pipelines due to transient locks

### Where it is used

Before Terraform operations that modify state (apply, promotion steps)

In workflows where concurrency is possible (manual dispatch, environment promotion, drift checks)

### Why this approach

Keeps pipelines deterministic and stable

Avoids relying on GitHub Actions concurrency limits alone

Mirrors how production platform teams handle Terraform locking in shared environments

This script is intentionally small and focused. It exists purely to enforce state safety, not workflow logic.

---

## Security Scanning (tfsec)

Security scanning is integrated using **tfsec**.

### Behavior

* Scans Terraform code for misconfigurations
* Enforces minimum severity thresholds
* Runs as part of CI, not after deployment

### Philosophy

Security findings are treated as **engineering feedback**, not noise. Findings are reviewed, fixed, or explicitly justified.

---

## Blue / Green Deployment Logic

The pipeline supports **blue/green-style infrastructure switching** using Terraform variables.

* Active color is controlled via CI input
* No manual state editing
* Enables safe promotion without redeploying everything

This pattern allows controlled traffic switching and safer rollouts.

---

## Terraform Execution Standards

All Terraform runs follow strict rules:

* `terraform fmt` enforced
* `terraform validate` before plan
* Explicit backend configuration
* No local state usage
* No interactive prompts

These rules ensure reproducibility and CI safety.

---

## Failure Handling & Observability

The CI/CD system is designed to:

* Fail fast on configuration errors
* Surface meaningful logs
* Avoid silent partial failures
* Make rollback and diagnosis straightforward

---

## Design Principles Recap

* Separation of concerns
* Explicit lifecycle management
* Security-first authentication
* Automation-safe Terraform usage
* Production-aligned workflows

---

## Audience

This CI/CD setup is intended to reflect **real-world platform engineering practices** and is suitable as:

* A learning reference
* A portfolio project
* A foundation for production systems

---



