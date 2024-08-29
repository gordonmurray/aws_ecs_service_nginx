terraform {

  required_version = "1.9.3"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.56.0"
    }
  }

}

provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "gordonmurray"

  default_tags {
    tags = {
      Name = "terraform_aws_ecs_service"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
