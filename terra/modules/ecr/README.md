# ============================================================
#  ECR MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The ECR module provisions a secure AWS Elastic Container
Registry (ECR) repository for container images.

It includes a lifecycle policy that automatically expires
older images, retaining only the most recent versions to
manage storage efficiently.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## ECR Repository
- Repository with configurable name (default: ecr-pyfleet)
- Image tag mutability set to MUTABLE to allow overwriting tags
- Tagged with repository name

## ECR Lifecycle Policy
- Automatically deletes older images, keeping the last 10
- Helps maintain repository size and reduces storage costs

# ------------------------------------------------------------
#  INPUTS
#
``` ------------------------------------------------------------
+-----------+-------------------------+------------+
| Variable  | Description             | Default    |
+-----------+-------------------------+------------+
| repo_name | Name of the ECR repo    | ecr-pyfleet|
| region    | AWS region for repo     | us-east-1  |
+-----------+-------------------------+------------+
```
# ------------------------------------------------------------
#  OUTPUTS
#
``` ------------------------------------------------------------
+---------+-------------------------------------------------+
| Output  | Description                                     |
+---------+-------------------------------------------------+
| repo_url| Repository URL for pushing Docker images       |
+---------+-------------------------------------------------+
```
# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
- Creates an ECR repository with the specified name
- Applies a lifecycle policy to expire older images beyond the last 10
- Repository is ready for Docker login and pushing images

# ------------------------------------------------------------
#  USAGE NOTES
# ------------------------------------------------------------
- Used `repo_url` output to tag and push Docker images from CI/CD pipelines
- Lifecycle policy ensures storage remains under control automatically
- Ideal for containerized applications requiring a private, versioned image registry
