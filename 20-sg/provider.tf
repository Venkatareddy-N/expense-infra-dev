terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "venkatswan"           #s3-bucket name
    key            = "expense-infra-dev-sg" # every repo should have unique S3-key
    region         = "us-east-1"
    dynamodb_table = "venkat-db" # dynamoDB table name
  }
}

provider "aws" {
  region = "us-east-1"
}