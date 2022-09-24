terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket = "tfstate-atimot-terraform-aws-my-project"
    key = "terraform.tfstate"
    region = "ap-northeast-1"
  }

  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 4.0"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
