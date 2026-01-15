
resource "aws_kms_key" "ecr" {
  description         = "KMS key for ECR encryption"
  enable_key_rotation = true
}

resource "aws_kms_key" "logs" {
  description         = "KMS key for CloudWatch logs"
  enable_key_rotation = true
}

output "ecr_kms_key_arn" {
  value = aws_kms_key.ecr.arn
}

output "logs_kms_key_arn" {
  value = aws_kms_key.logs.arn
}
