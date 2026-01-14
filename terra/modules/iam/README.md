# ============================================================
#  IAM MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The IAM module provisions an IAM role and instance profile
for EC2 instances, allowing them to securely access AWS
services such as ECR.

It attaches a managed policy (ECR read-only by default) and
creates an instance profile that can be used in launch
templates or Auto Scaling Groups.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## IAM Role
- Role assumed by EC2 instances
- Trust policy allows EC2 to assume the role
- Tagged for identification and organization

## IAM Role Policy Attachment
- Attaches a managed policy (ECR read-only by default) to the EC2 role
- Can be extended to attach additional policies as needed

## IAM Instance Profile
- Instance profile associated with the IAM role
- Required for EC2 instances to assume the role

# ------------------------------------------------------------
#  INPUTS
# ------------------------------------------------------------
+------------------------+-------------------------------------------+-------------------------------------------------+
| Variable               | Description                               | Default                                         |
+------------------------+-------------------------------------------+-------------------------------------------------+
| role_name              | IAM role name for EC2 instances           | ec2-ecr-role                                   |
| instance_profile_name  | IAM instance profile name for EC2         | ec2-ecr-profile                                |
| ecr_policy_arn         | Managed policy ARN to attach (ECR read-only)| arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly |
| tags                   | Optional tags for IAM resources           | { Project = "pyfleet", Owner = "DevOps" }      |
+------------------------+-------------------------------------------+-------------------------------------------------+

# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
+------------------------+---------------------------------------------------+
| Output                 | Description                                       |
+------------------------+---------------------------------------------------+
| instance_profile_name  | Name of the IAM instance profile for EC2 instances|
+------------------------+---------------------------------------------------+

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
- Creates an IAM role with a trust policy allowing EC2 to assume the role
- Attaches a managed policy to grant permissions (default: read-only access to ECR)
- Creates an instance profile linked to the IAM role for EC2 launch templates and ASGs
- Resources are tagged for clarity and management

# ------------------------------------------------------------
#  USAGE NOTES
# ------------------------------------------------------------
- Use `instance_profile_name` output in EC2 launch templates or Auto Scaling Groups
- Additional policies can be attached by extending the module if EC2 instances need more permissions
- Ensures secure, least-privilege access for EC2 workloads interacting with AWS services
