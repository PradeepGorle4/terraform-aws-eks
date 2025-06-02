terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }

  backend "s3" {
    bucket         = "82s-expense-infra-dev-remote-state"
    key            = "expense-dev-rds" # Unique key should be used with in the bucket, this will dump in our bucket only if others have same key and access.
    region         = "us-east-1"
    dynamodb_table = "82s-expense-infra-dev-state-lock"
  }
}


provider "aws" {
  # Configuration options
  region = "us-east-1"
}