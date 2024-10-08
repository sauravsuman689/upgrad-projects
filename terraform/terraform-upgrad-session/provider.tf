terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.63.0"
    }
  }

  backend "s3" {
    bucket = "sauravteraforms3"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  # Configuration options
    region = "us-east-1"
}
