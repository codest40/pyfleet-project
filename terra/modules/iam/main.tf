# -------------------------
# IAM Role for EC2
# -------------------------
# This role will be assumed by EC2 instances (via instance profile) 
# so they can access AWS services like ECR.
resource "aws_iam_role" "ec2_role" {
  name = var.role_name  # role name comes from variables for flexibility

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" } # EC2 assumes this role
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags  # optional tags for organization
}

# -------------------------
# Attach Policies to Role
# -------------------------
# Here we attach managed policies (like ECR read-only) to the EC2 role.
# Can be extended to other policies if needed.
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ecr_policy_arn  # from variable for flexibility
}

# -------------------------
# IAM Instance Profile
# -------------------------
# EC2 instances need an instance profile to use the IAM role.
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.instance_profile_name  # configurable via variable
  role = aws_iam_role.ec2_role.name
}
