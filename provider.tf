terraform {
  required_version = ">= 0.12.31"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.26"
    }
  }
}
provider "aws" {
  region = "eu-west-1"
}