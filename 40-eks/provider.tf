terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.95.0"  # Adjust as needed for compatibility
      
    }
  }

  backend "s3" {
    bucket         = "expense-infra-eks-dev-state-locking"
    key            = "expense-dev-eks-eks" # Unique key should be used with in the bucket, this will dump in our bucket only if others have same key and access.
    region         = "us-east-1"
    use_lockfile = true
 }
}
provider "aws" {
  # Configuration options
  region = "us-east-1"
}