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

variable "container_image_tag" {
  description = "Immutable ECR image tag to deploy"
  type        = string
  default     = "33e9b7793da0ad1711ead9f92832fa9781a6a9dc"
}

variable "ami_id" {
  description = "Pinned Amazon Linux AMI for the dev environment"
  type        = string
  default     = "ami-02b3d83d84b07786d"
}