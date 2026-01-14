
terraform {
  backend "s3" {
    bucket         = "tf-backend-pyfleet"
    key            = "pyfleet/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-pyfleet"
    encrypt        = true
    #    profile        = admin-codest
  }
}
