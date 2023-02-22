# Generic Variables
# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}
# Business Division
variable "division" {
  description = "project or department in the large organization this Infrastructure belongs"
  type        = string
  #default = "sales"
  default = "jingood2"
}

# Project
variable "component" {
  description = "compoment name"
  type        = string
  default = "vpc"
}

variable "backend_s3_bucket" {
  description = "backend s3 bucket"
  type        = string
  default = "jingood2"
}
####################################################################

# Define Local Values in Terraform
locals {
  owners      = var.division
  environment = var.environment
  component   = var.component
  name        = "${var.division}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}
