# PyFleet — Cloud Infrastructure & CI/CD Platform

PyFleet is an AWS-based infrastructure and CI/CD project designed to demonstrate a **production-oriented DevOps / Platform Engineering workflow** using Infrastructure as Code, secure CI/CD pipelines, and cloud-native best practices.

This repository focuses on correctness, separation of concerns, and gradual infrastructure maturity.

---

## Project Scope

The project covers two main areas:

- **Infrastructure as Code (IaC)** using Terraform
- **CI/CD automation** using GitHub Actions with AWS OIDC authentication

Each area is fully implemented and documented **inside its own directory** to keep the root clean and maintainable.

---

## Repository Structure

```text
.
├── .github/
│   ├── workflows/
│   │   ├── cicd-doc/        # CI/CD documentation
│   │   └── *.yml            # GitHub Actions workflows
│
├── terra/                   # Terraform infrastructure (IaC)
│   ├── modules/             # Reusable Terraform modules
│   └── README.md            # Full IaC documentation
│
├── info/                    # Project notes and references
├── push.sh                  # Helper script
├── .gitignore
└── README.md                # (this file)

# Infrastructure as Code (Terraform)

The terra/ directory contains the full AWS infrastructure defined using Terraform, including:

Networking (VPC, subnets, routing)

Compute and scaling components

Load balancing and CloudFront

WAF and security controls

Remote state backend (S3 + DynamoDB)

Modular design

📘 Full Terraform documentation:
➡️ terra/README.md


#CI/CD (GitHub Actions)

The CI/CD pipeline is implemented using GitHub Actions and includes:

Secure AWS authentication via OIDC (no static credentials)

Separate backend lifecycle actions (create / destroy)

Terraform formatting, validation, and planning

Security scanning with tfsec

Environment-aware execution (dev / prod)

Non-interactive, automation-safe Terraform runs

📘 Full CI/CD documentation:
➡️ .github/workflows/cicd-doc/README.md


# Design Principles

Clear separation between infrastructure, CI/CD, and documentation

Explicit backend lifecycle management

Non-interactive, automation-first Terraform execution

Security-first authentication (OIDC, no long-lived secrets)
