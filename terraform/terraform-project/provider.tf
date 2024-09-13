terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  backend "s3" {
    bucket = "sauravselfteraformsprojectbucket"
    key    = "selfstate/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-dynamo-lock"
  }
}
provider "aws" {
  # Configuration options
  region = "us-east-1"
}
