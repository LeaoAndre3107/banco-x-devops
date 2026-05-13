terraform {
  backend "s3" {
    bucket         = "bancox-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bancox-terraform-lock"
    encrypt        = true
  }
}