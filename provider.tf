terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.27.0"
    }
  }
}
####### Regions Mapping Start #######
provider "aws" {
    region = "ap-south-1"
    profile = "nn"
}

provider "aws" {
    region = "us-east-1"
    alias = "usea1"
    profile = "nn"
}
