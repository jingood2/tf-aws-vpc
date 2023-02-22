# Terraform Block
terraform {
  required_version = "~> 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.76.1"
    }
  }

  backend "s3" {}
  #backend "s3" {
  #  bucket  = var.backend_s3_bucket
  #  key     = "${var.component}/terraform.tfstate"
  #  region  = var.aws_region
  #  encrypt = true
  #  profile = "jingood2"
  #}
  #backend "remote" {
  #  hostname = "app.terraform.io"
  #  organization = "jingood2"

  #  workspaces {
  #    prefix = "helloworld-"
  #  }
  #}
}

# Provider Block
provider "aws" {
  region = var.aws_region
  #assume_role {
  #  role_arn = "arn:aws:iam::783857413761:role/GithubOIDCRole "
  #}
  profile = "default"
}
/*
Note-1:  AWS Credentials Profile (profile = "default") configured on your local desktop terminal
$HOME/.aws/credentials
*/
