terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "finops/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true

    # --- required for FakeCloud / LocalStack ---
    endpoints = {
      s3       = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
    }
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}

provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  # Essential flags for local emulators like FakeCloud
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  default_tags {
    tags = {
      Project      = "FinOps-Automator"
      Environment  = "Development"
      ManagedBy    = "Terraform"
      AutoShutdown = "True"
    }
  }
}