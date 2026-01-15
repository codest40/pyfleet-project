
terraform {
  backend "s3" {
    bucket         = "pyfleet-backend-tf"
    key            = "pyfleet/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "pyfleet-lock-tf"
    encrypt        = true
    #    profile        = admin-codest
  }
}
