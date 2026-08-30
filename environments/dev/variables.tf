variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the development VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "AWS region for the dev environment"
  type        = string
  default     = "us-east-1"
}