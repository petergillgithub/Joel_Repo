terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.37.0"
    }
  }



   backend "s3" {
    bucket = "demo-s3-bucket-peter"
    key    = "eks_vpc/dev/terraformstate.tf"
    region = "eu-west-2"
  }
}