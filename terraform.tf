
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

terraform {
  # AWS Providerバージョン指定
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # terraformバージョン指定
  required_version = ">= 1.5.0"

  # tfstate S3格納
  backend "s3" {}
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Managed = "Terraform"
      Project = var.project
      Env     = var.env
    }
  }
}
